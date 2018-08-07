class Wap::OrdersController < Wap::BaseController
  before_filter :find_order, only: [:show, :cancel, :destroy, :complete, :refund, :confirm, :update_address]
  before_filter do
    @hidden_footer = true
  end

  skip_filter :auth, only: [:pre_alipay]

  def index
    type = case params[:type]
    when 'pending'
      EcOrder::PENDING
    when 'delivered'
      [EcOrder::WAITING, EcOrder::DELIVERED, EcOrder::ARRIVED, EcOrder::CONFIRMED]
    when 'confirmed'
      EcOrder::CONFIRMED
    end

    params[:ajaxdata] ||= {}

    @orders = ['all', nil].include?(params[:type]) ? @user.ec_orders : @user.ec_orders.where(status: type)
    @total_count = @orders.count
    @orders = @orders.order('created_at desc').page(params[:ajaxdata][:page]).per(params[:ajaxdata][:pagesize])

    data = []
    @orders.each do |order|
      data << {order_id: order.id, state: order.status, ordernumber: order.order_no, self_pickup: order.self_pickup, logistic_no: order.logistic_no, desc: order.status_name, shopname: order.ec_shop.try(:name) || '在线商城',
        list: order.ec_order_items[0..0]}
    end

    respond_to do |format|
        format.html { render 'index' }
        format.json { render json: {data: data, code: 1, total: @total_count} }
    end
  end

  def show
    @order.check_order_expire!

    @hidden_footer = true

    @default_address = @user.ec_addresses.where(is_default: true).first || @user.ec_addresses.first
    @timearr = []
    EcDiningTime.order("start_at asc").each do |dt|
      @timearr << {value: dt.id, name: "#{dt.start_at.try(:strftime, "%H:%M")}-#{dt.end_at.try(:strftime, "%H:%M")}"}#.to_json
    end
  end

  def update_address
    address_info = params[:address] || {}

    if params[:address_type].to_i == 1
      @order.assign_attributes(
        delivery_type: 1,
        province_id: address_info[:sheng],
        city_id: address_info[:shi],
        district_id: address_info[:qu],
        address: address_info[:street],
        username: address_info[:name],
        mobile: address_info[:phone]
      )
    elsif params[:address_type].to_i == 2
      shop = EcShop.pass.where(id: address_info[:aid]).first
      dining_time = EcDiningTime.where(id: address_info[:timepart]).first

      @order.assign_attributes(
        delivery_type: 2,
        ec_shop_id: shop.id,
        province_id: shop.province_id,
        city_id: shop.city_id,
        district_id: shop.district_id,
        address: shop.address,
        username: address_info[:name],
        mobile: address_info[:phone],
        dining_date: Date.parse(address_info[:day]),
        start_dining_at: dining_time.start_at,
        end_dining_at: dining_time.end_at
      )
    else
      return render json: {code: 0}
    end

    if @order.save
      render json: {code: 1}
    else
      render json: {code: 0}
    end
  end

  def pre_alipay
    @order = EcOrder.where(id: params[:id]).first

    return render text: '找不到此订单' unless @order

    @order.payment.alipay!
    @order.alipay!

    @payment_params = {
      callback_url: callback_payments_url,
      notify_url: notify_payments_url,
      merchant_url: wap_order_url(@order)
    }
    @order.payment.update_attributes(@payment_params)
  end

  def new
    second_shop_id = @user.ec_cart_items.where(id: params[:p_ids]).pluck(:ec_shop_id).delete_if{|i| i==0}.first if params[:from] == 'cart'
    @shop = EcShop.pass.where(id: session[:shop_id] || second_shop_id).first
    @default_address = @user.ec_addresses.where(is_default: true).first || @user.ec_addresses.first
    @timearr = []
    EcDiningTime.order("start_at asc").each do |dt|
      @timearr << {value: dt.id, name: "#{dt.start_at.try(:strftime, "%H:%M")}-#{dt.end_at.try(:strftime, "%H:%M")}"}#.to_json
    end
  end

  def calc_freight
    data = params[:data] || {}
    address = data['address'] || {}
    address_info = data['address']['info'] || {}
    arr = data['list'].collect {|k, v| v}
    item_ids = arr.collect {|a| a['tid']}
    @order = @user.ec_orders.new

    arr.each do |a|
      @order.ec_order_items.new(ec_item_id: a[:tid])
    end

    value = 0
    @order.ec_order_items.each do |order_item|
      value += order_item.freight_calc(address_info[:shi])
    end

    render json: {value: value, code: 1}
  end

  def create
    data = params[:data] || {}
    address = data['address'] || {}
    address_info = data['address']['info'] || {}
    arr = data['list'].collect {|k, v| v}
    cart_item_ids = arr.collect {|a| a['pid']}
    self_pickup = data['self_pickup'] || {}
    invoice = data['fapiao'] || {}

    if address['type'].to_i == 1
      @order = @user.ec_orders.new(
        delivery_type: address['type'],
        province_id: address_info['sheng'],
        city_id: address_info['shi'],
        district_id: address_info['qu'],
        address: address_info['street'],
        username: address_info['name'],
        mobile: address_info['phone'],
        self_pickup: self_pickup['isget'],
        need_invoice: invoice['isget'],
        invoice_type: invoice['type'],
        invoice_title: invoice['title']

      )
    elsif address['type'].to_i == 2
      shop = EcShop.where(id: address_info['aid']).first
      dining_time = EcDiningTime.where(id:address_info['timepart']).first
      @order = @user.ec_orders.new(
        delivery_type: address['type'],
        ec_shop_id: shop.id,
        province_id: shop.province_id,
        city_id: shop.city_id,
        district_id: shop.district_id,
        address: shop.address,
        username: address_info['name'],
        mobile: address_info['phone'],
        dining_date: Date.parse(address_info['day']),
        start_dining_at: dining_time.start_at,
        end_dining_at: dining_time.end_at,
        self_pickup: self_pickup['isget'],
        need_invoice: invoice['isget'],
        invoice_type: invoice['type'],
        invoice_title: invoice['title']
      )
    end

    if @order.nil?
      respond_to do |format|
        format.json { return render json: {data: @order, code: -1, msg: '错误的配送类型'} }
      end
    end

    @order.source_type = session[:source_type].to_i
    @order.source_shop_id = session[:source_shop_id].to_i if @order.offline? && session[:source_shop_id].to_i != 0

    if data[:submit_type] == 'single'
      single_data = data['list']['0']

      single_item = EcItem.where(id: single_data['tid']).first

      if single_item.nil?
        respond_to do |format|
          format.json { return render json: {data: @order, code: -1, msg: '当前订单是空的，不能提交'} }
        end
      end

      single_product = single_item.ec_product

      @order.ec_order_items.new(
        ec_shop_id: 0,
        ec_item_id: single_item.id,
        product_name: single_product.name,
        item_name: single_item.name,
        pic_key: single_product.ec_pictures.first.try(:pic_key),
        qty: single_data['num'].to_i,
        price: single_item.price,
        total_price: single_item.price * single_data['num'].to_i,
        total_pay_price: single_item.price * single_data['num'].to_i
      )
    elsif data[:submit_type] == 'multi'
      arr.each do |a|
        @item = EcItem.where(id: a['tid'].to_i).first

        if @item.present? && a['num'].to_i > 0
          @order.ec_order_items.new(
            ec_shop_id: 0,
            ec_item_id: @item.id,
            product_name: @item.ec_product.name,
            item_name: @item.name,
            pic_key: @item.ec_product.ec_pictures.first.try(:pic_key),
            qty: a['num'].to_i,
            price: @item.price,
            total_price: @item.price * a['num'].to_i,
            total_pay_price: @item.price * a['num'].to_i
          )
        end
      end
    else
      @user.ec_cart_items.where(id: cart_item_ids).each do |cart_item|
        @order.ec_order_items.new(
          ec_shop_id: 0,
          ec_item_id: cart_item.ec_item_id,
          product_name: cart_item.ec_item.ec_product.name,
          item_name: cart_item.ec_item.name,
          pic_key: cart_item.ec_item.ec_product.ec_pictures.first.try(:pic_key),
          qty: cart_item.qty,
          price: cart_item.ec_item.price,
          total_price: cart_item.ec_item.price * cart_item.qty,
          total_pay_price: cart_item.ec_item.price * cart_item.qty,
        )
      end
    end

    if @order.ec_order_items.blank?
      respond_to do |format|
        format.json { return render json: {data: data, code: -1, msg: '当前订单是空的，不能提交'} }
      end
    end

    if @order.save
      data = {order_id: @order.id, site_id: Site.first.id, out_trade_no: @order.payment.try(:out_trade_no), openid: @user.wx_user.openid}

      respond_to do |format|
        format.json { return render json: {data: data, code: 1} }
      end
    else
      respond_to do |format|
        format.json { return render json: {data: @order, code: 0, msg: '库存不足，请返回购物车检查数量'} }
      end
    end
  end

  def confirm
    render json: {data: @order, code: @order.confirmed! ? 1 : 0}
  end

  def cancel
    render json: {data: @order, code: @order.canceled! ? 1 : 0}
  end

  def refund
    render json: {data: @order, code: @order.refunding! ? 1 : 0}
  end

  def complete
    render json: {data: @order, code: @order.completed! ? 1 : 0}
  end

  def destroy
    render json: {data: @order, code: @order.deleted! ? 1 : 0}
  end

  private

    def find_order
      @order = @user.ec_orders.where(id: params[:id]).first
    end
end
