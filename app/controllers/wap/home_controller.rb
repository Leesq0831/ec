class Wap::HomeController < Wap::BaseController
  def index
    @slides = EcSlide.all
    @categories = EcCategory.product_category
    @ec_shop_recommends = EcShopRecommend.homepage
    @pop_banner = EcSlide.pop_banner.last
    # @show_pop_banner = @pop_banner

    if @pop_banner.present? && @user.ec_slide_users.where(ec_slide_id: @pop_banner.id).where("date(ec_slide_users.created_at) = ?", Date.today).blank?
      @show_pop_banner = @pop_banner
      @show_pop_banner.ec_slide_users.create(user_id: @user.id)
    end
  end

  def more
    @items = EcItem.onshelf.order('display_sold_qty desc, sold_qty desc').page(params[:page]).per(6)
    @total_count = EcItem.onshelf.order('display_sold_qty desc, sold_qty desc').count

    data = []

    @items.each do |item|
      data << {id: item.id, img: item.ec_product.ec_pictures.first.try(:pic_url), name: item.ec_product.name, price: item.price, sold_qty: item.display_sold_qty || item.sold_qty || 0}
    end

    respond_to do |format|
      format.json { render json: {data: data, code: 1, total: @total_count} }
    end
  end

  def search
    @products = EcProduct.onshelf.where("name like ?", "%#{params[:key]}%").order("ec_products.position asc").page(params[:page]).per(params[:pagesize])
    @total_count = EcProduct.onshelf.where("name like ?", "%#{params[:key]}%").count

    @user.ec_search_histories.create(keyword: params[:key]) if params[:key].present?

    data = []
    @products.each do |product|
      ec_item = product.ec_item
      data << {id: ec_item.id, key: product.name, pid: ec_item.id, name: product.name, imgsrc: product.ec_picture.try(:pic_url), price: ec_item.price, sold: product.ec_items.show.sum(:display_sold_qty)}
    end

    respond_to do |format|
      format.html { render 'search' }
      format.json { render json: {data: data, code: 1, total: @total_count} }
    end
  end

  def recohis
    @keywords = EcSearchHistory.group("keyword").order("count(keyword) desc").limit(6).pluck(:keyword)

    respond_to do |format|
      format.html { render 'index' }
      format.json { render json: {data: @keywords, code: 1} }
    end
  end
end