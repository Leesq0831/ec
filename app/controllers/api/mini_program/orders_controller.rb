class Api::MiniProgram::OrdersController < Api::MiniProgram::BaseController
  skip_before_filter :verify_authenticity_token
  before_filter :find_order, only: [:show, :cancel, :destroy,:confirm, :edit]

  def index
    if params['status'].present?
      @orders = @current_user.ec_orders.where(status: params['status'].to_i).order("ec_orders.created_at desc")
    else
      @orders = @current_user.ec_orders.orders_all.order("ec_orders.created_at desc")
    end
  end

  def show
    respond_to :json
  end

  def new
    if params[:from_type] == "item"
      @order = true
      @ec_item = @current_site.ec_items.where(id: params[:item_id])
      @qty = params[:qty]
    else
      @order = false
      cart_item_ids = params[:cart_items].split(",")
      @cart_items = @current_user.ec_cart_items.where(id: cart_item_ids)
    end
    @address = @current_user.ec_addresses.where(is_default: true).try(:first) || @current_user.ec_addresses.try(:first)
  end

  def create
    @order = @current_user.ec_orders.new(params[:ec_order])
    if @order.save
      @current_user.ec_cart_items.where(id: params[:ids].split(",")).destroy_all if params[:ids].size > 0
      return render json: {code: 1, errormsg: "ok", pay_type: @order.pay_type, order_no: @order.order_no}
    else
      return render json: {code: -1, errormsg: @order.errors.messages}
    end
  end

  def get_address
    @address = @current_user.ec_addresses.find_by_id(params[:address_id].to_i)
    item_ids = params[:item_id][1..-2].split(",")
    qty = params[:qty][1..-2].split(",")
    logistic = 0.00

    item_ids.each_with_index do |id, i|
      item = @current_site.ec_items.find_by_id(id.to_i)
      logistic = logistic + (item.logistic(@address.city_id, qty[i].to_i)).round(2)
    end

    return render json: {
      address: [@address.id, @address.username, @address.mobile, @address.is_default,
        "#{@address.province.try(:name)}" + "#{@address.city.try(:name)}" + "#{@address.district.try(:name)}" + "#{@address.address}"
      ],
      logistic: logistic
    }
  end

  def destroy
    render json: {code: @order.deleted! ? 1 : 0 }
  end

  def cancel
    render json: {code: @order.canceled! ? 1 : 0 }
  end

  def confirm
    render json: {code: @order.update_attributes(status: 5, completed_at: Time.now) ? 1 : 0 }
  end

  def edit
    # return redirect_to "https://m.kuaidi100.com/result.jsp?nu=#{@order.logistic_no}"
    resp = HTTParty.post("http://www.kuaidi100.com/autonumber/autoComNum?text=#{@order.logistic_no}")
    json_body = JSON.parse(resp.body)
    comCode = json_body["auto"][0]["comCode"]
    resp = HTTParty.get("http://www.kuaidi100.com/query?type=#{comCode}&postid=#{@order.logistic_no}")
    json_body = JSON.parse(resp.body)

    if json_body["message"] == "ok"
      render json: {code: 1, errormsg: "ok", data: json_body["data"], name: @order.ec_logistic_company.try(:name), no: @order.logistic_no}
    else
      render json: {code: -1, errormsg: "#{json_body["message"]}" }
    end

  end

  private

    def find_order
      @order = @current_user.ec_orders.find_by_id(params[:id].to_i) rescue nil
      return nil unless @order 
      @order.check_order_expire! if @order.pending?
    end

end
