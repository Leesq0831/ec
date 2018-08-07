class Wap::ShopsController < Wap::BaseController
  before_filter :find_shop, only: [:show, :goto, :product_list]

  def index
    # @search = EcShop.pass.search(params[:search])
    # @shops = @search.order("created_at desc").page(params[:page])
    @shops_arr = EcShop.pass.sort_by_distance(@user)
  end

  def show
    @hidden_footer = true
    @shop = EcShop.pass.find(params[:id])
    @ec_shop_recommends = @shop.ec_shop_recommends.detail
  end

  def goto
    session[:shop_id] = @shop.id
    redirect_to wap_items_path
  end

  def product_list
    session[:source_type] = 1
    session[:source_shop_id] = @shop.id
    session[:shop_id] = @shop.id

    params[:data] ||= {}
    @products = @shop.ec_products
    @total_count = @products.count
    @products = @products.order("ec_products.position asc").page(params[:data][:page]).per(params[:data][:pagesize])

    data = []
    @products.each do |product|
      data << {imgsrc: product.ec_picture.try(:pic_url), pid: product.ec_item.id, name: product.name, price: product.ec_item.price, sold: product.ec_item.sold_qty_text}
    end

    respond_to do |format|
      format.html
      format.json { render json: {data: data, code: 1, total: @total_count} }
    end
  end

  private

    def find_shop
      @shop = EcShop.pass.where(id: params[:id]).first
    end

end
