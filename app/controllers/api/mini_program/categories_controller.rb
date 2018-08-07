class Api::MiniProgram::CategoriesController < Api::MiniProgram::BaseController
  before_filter :set_wx_user, only: [:product]

  def index
    @categories = @current_account.ec_categories.onshelf.product_category.search(params[:search]).to_a
    respond_to do |format|
      format.json { render json: {categories: @categories, icon: @categories.map{|c| c.icon_url}}}
    end
  end

  def category
    @categories = @current_account.ec_categories.onshelf.product_category.limit(8)
    # respond_to do |format|
    #   format.json { render json: {categories: @categories, icon: @categories.map{|c| c.icon_url}}}
    # end
    respond_to :json
  end

  def show
    @category = @current_account.ec_categories.onshelf.find(params[:id].to_i)
    return render json: {products: []} unless @category
    @products = @category.ec_products
    respond_to do |format|
      format.json {render "api/mini_program/home/search" }
    end
  end

  #商品详情
  def product
    @cart_count = @current_wx_user.nil? ? 0 : @current_user.ec_cart_items.sum(:qty)
    @ec_item = @current_account.ec_items.find_by_id(params[:item_id].to_i)
    return render json: {code: -1} unless @ec_item
    @ec_product = @ec_item.ec_product
    respond_to :json
  end

end
