class Wap::ItemsController < Wap::BaseController
  before_filter :find_item, only: [:show, :add_cart, :add_fav, :del_fav, :check_qty, :calc_freight]

  def index
    @items = params[:category_id].present? ? EcItem.product.onshelf.joins(:ec_product).where(ec_products: {ec_category_id: params[:category_id]}) : EcItem.product.onshelf

    params[:data] ||= {}

    @items = params[:data][:type].to_i == 0 ? @items : @items.onshelf.joins(:ec_product).where(ec_products: {ec_category_id: params[:data][:type]})

    price = EcPrice.where(id: params[:data][:price].to_i).first
    if price.present?
      @items = @items.where("price >= ? and price < ?", price.min_price, price.max_price)
    end

    tag = EcTag.product_tag.where(id: params[:data][:scene].to_i).first
    if tag.present?
      @items = @items.joins(:ec_product).where(ec_products: {id: tag.ec_products.pluck(:id)})
    end

    if ['asc', 'desc'].include?(params[:data][:price].to_s)
      order = "ec_items.price #{params[:data][:price].to_s}, ec_items.display_sold_qty desc, ec_items.sold_qty desc"
    else
      order = "ec_products.position asc, ec_items.display_sold_qty desc, ec_items.sold_qty desc"
    end
    @items = @items.joins(:ec_product).order(order).page(params[:data][:page]).per(params[:data][:pagesize])

    data = []
    @items.each do |item|
      data << {imgsrc: item.ec_product.ec_picture.try(:format_pic_url), pid: item.id, name: item.ec_product.name, price: item.price, sold: item.display_sold_qty || item.sold_qty || 0}
    end

    respond_to do |format|
      format.html
      format.json { render json: {data: data, code: 1} }
    end
  end

  def show
    @default_city = City.where(id: session[:default_city_id].to_i).first || City.where(id: 73).first
    @hidden_footer = true
    params[:jdata] ||= {}
    session[:shop_id] = params[:shop_id] if params[:shop_id].to_i > 0
    @total_count = @item.ec_comments.normal.judge_rating(params[:jdata][:type]).count
    @comments = @item.ec_comments.normal.judge_rating(params[:jdata][:type]).page(params[:jdata][:page]).per(params[:jdata][:pagesize])

    data = []
    @comments.each do |comment|
      data << {headimg: comment.user.wx_user.headimgurl || '/wap/img/head01.jpg', pid: @item.id, name: comment.user.wx_user.nickname || '匿名用户', star: comment.star, time: comment.created_at.try(:strftime, "%Y-%m-%d %H:%M"), comment: comment.content, reply: comment.reply}
    end

    respond_to do |format|
      format.html
      format.json { render json: {code: 1, data: data, total: @total_count} }
    end
  end

  def calc_freight
    data = params[:ship_data] || {}
    @order_item = EcOrderItem.new(ec_item_id: @item.id)
    value = @order_item.freight_calc(data[:p_city_id]) || 0
    session[:default_city_id] = data[:p_city_id]

    render json: {value: value, code: 1}
  end

  def add_cart
    return render json: {code: 0} if @item.qty < 1

    @cart_item = @user.ec_cart_items.where(ec_item_id: @item.id).first_or_initialize(ec_shop_id: session[:shop_id], qty: 1, original_price: @item.price)

    if @cart_item.new_record? && @cart_item.save
      session[:shop_id] = nil
      render json: {code: 1}
    elsif @cart_item.increase!
      session[:shop_id] = nil
      render json: {code: 1}
    else
      render json: {code: 0}
    end
  end

  def add_fav
    @fav = @user.ec_favorites.where(ec_item_id: @item.id).first_or_initialize

    if @fav.new_record?
      if @fav.save
        render json: {code: 1}
      else
        render json: {code: 0}
      end
    else
      @fav.destroy
      render json: {code: 2}
    end
  end

  def check_qty
    render json: { code: @item.qty - params[:qty].to_i >= 0 ? 1 : 0 }
  end

  def check_qty_more
    data = params[:data] || {}
    arr = data.collect{|k, v| v}
    arr.each do |a|
      ec_item = EcItem.where(id: a[:tid]).first
      if ec_item.gift?
        return render json: {code: 0, msg: "#{a[:name]} #{a[:pnor]} 赠品不支持购买"}
      elsif ec_item.qty < a[:num].to_i
        return render json: {code: 0, msg: "#{a[:name]} #{a[:pnor]} 库存不足, 再来一单失败"}
      end
    end

    render json: {code: 1}
  end

  private

    def find_item
      @item = EcItem.where(id: params[:id]).first
      return render text: '商品已下架' unless @item.onshelf?
      @product = @item.ec_product if @item.present?
    end
end
