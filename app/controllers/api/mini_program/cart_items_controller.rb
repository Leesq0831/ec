class Api::MiniProgram::CartItemsController < Api::MiniProgram::BaseController

  before_filter :find_cart_item, only: [:increase, :decrease]

  def index
    @cart_items = @current_user.ec_cart_items.order("created_at desc")
  end

  def show
    @cart_item = @current_user.ec_cart_items.where(params[:id]).first
  end

  def increase
    respond_to do |format|
      format.json { render json: {code: @cart_item.increase! ? 1 : 0} }
    end
  end

  def decrease
    respond_to do |format|
      format.json { render json: {code: @cart_item.decrease! ? 1 : 0} }
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
    render json: {result: {code: 1}}
  end

  def move_to_fav
    @cart_items = @current_user.ec_cart_items.where(id: params[:arr])
    return render json: {code: 0} if @cart_items.blank?
    render json: {code:  @cart_items.move_to_fav ? 1 : 0}
  end

  def remove_all
    @cart_items = @current_user.ec_cart_items.where(id: params[:arr])

    respond_to do |format|
      format.json { render json: {code: @cart_items.present? && @cart_items.destroy_all ? 1 : 0} }
    end
  end

  private

    def find_cart_item
      @cart_item = @current_user.ec_cart_items.where(id: params[:id]).first
    end

end
