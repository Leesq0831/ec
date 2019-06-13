class Wap::CartItemsController < Wap::BaseController
  before_filter :find_cart_item, only: [:increase, :decrease]

  def index
    @order = @user.ec_orders.new
    @cart_items = @user.ec_cart_items.order("created_at desc")
    @activity = EcActivity.subscribe.first
  end

  def show
    @cart_item = @user.ec_cart_items.where(params[:id]).first
  end

  def increase
    if @cart_item.increase!
      respond_to do |format|
        format.json { render json: {code: 1} }
      end
    else
      respond_to do |format|
        format.json { render json: {code: 0} }
      end
    end
  end

  def decrease
    if @cart_item.decrease!
      respond_to do |format|
        format.json { render json: {code: 1} }
      end
    else
      respond_to do |format|
        format.json { render json: {code: 0} }
      end
    end
  end

  def check_qty
    data = params[:data] || {}
    arr = data.collect{|k, v| v if v[:selected].to_i == 1}.compact
    arr.each do |a|
      if EcItem.where(id: a[:tid]).first.qty < a[:num].to_i
        return render json: {code: 0, msg: "#{a[:name]} #{a[:pnor]} 库存不足, 请检查购物车"}
      end
    end

    render json: {code: 1}
  end

  def move_to_fav
    @cart_items = @user.ec_cart_items.where(id: params[:arr])
    return render json: {code: 0} if @cart_items.blank?

    if @cart_items.move_to_fav
      render json: {code: 1}
    else
      render json: {code: 0}
    end
  end

  def remove_all
    @cart_items = @user.ec_cart_items.where(id: params[:arr])

    if @cart_items.present? && @cart_items.destroy_all
      respond_to do |format|
        format.json { render json: {code: 1} }
      end
    else
      respond_to do |format|
        format.json { render json: {code: 0} }
      end
    end
  end

  private

    def find_cart_item
      @cart_item = @user.ec_cart_items.where(id: params[:id]).first
    end

end
