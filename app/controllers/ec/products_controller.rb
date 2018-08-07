class Ec::ProductsController < Ec::BaseController
  before_filter :find_product, only: [:edit, :show, :items, :update, :destroy, :onshelf, :offshelf, :update_sort]
  def index
    @search = @current_site.ec_products.show.search(params[:search])
    @products = @search.order("position asc").page(params[:page])
  end

  def new
    @product = @current_site.ec_products.new
    @product.ec_items.new
  end

  def create
    @product = @current_site.ec_products.new(params[:ec_product])
    if @product.save
      redirect_to items_ec_product_path(@product), notice: '保存成功'
    else
      flash[:alert] = "保存失败"
      render action: 'new'
    end
  end

  def update
    if @product.update_attributes(params[:ec_product])
      redirect_to ec_products_path, notice: '保存成功'
    else
      flash[:alert] = "更新失败"
      render action: 'edit'
    end
  end

  def update_sort
    @product.update_attributes(position: params[:position])
    render js: "showTip('notice', '修改成功');"
  end

  def items
    @items = @product.ec_items.show.order('created_at')
    respond_to do |format|
      format.html
      format.json { render json: @items }
    end
  end

  def stock
    @ec_items = @current_site.ec_items.show.where(ec_product_id: params[:ids])
    render layout: 'application_pop'
  end

  def stock_in
    @stock = @current_site.ec_stocks.create(params[:ec_stock])
    
    params[:ec_items].each do |ec_item|
      if ec_item[:qty].to_i > 0
        ec_stock_item = @current_site.ec_stock_items.create(ec_item_id: ec_item[:id].to_i, qty: ec_item[:qty].to_i, ec_stock_id: @stock.try(:id))
        ec_stock_item.effected
      end
    end
    flash[:notice] = '入库成功'
    render inline: "<script>parent.location.reload();</script>"
  rescue
    flash[:alert] = '入库失败'
    render inline: "<script>parent.location.reload();</script>"
  end

  def onshelf
    if @product.onshelf!
      redirect_to :back, notice: '上架成功'
    else
      redirect_to :back, alert: '上架失败'
    end
  end

  def offshelf
    if @product.offshelf!
      redirect_to :back, notice: '下架成功'
    else
      redirect_to :back, alert: '下架失败'
    end
  end

  def destroy
    @product.deleted!
    redirect_to :back, notice: '删除成功'
  end

  def onshelf_all
    if @current_site.ec_products.onshelf_all(params[:ids])
      redirect_to :back, notice: '批量上架成功'
    else
      redirect_to :back, alert: '批量上架失败'
    end
  end

  def offshelf_all
    if @current_site.ec_products.offshelf_all(params[:ids])
      redirect_to :back, notice: '批量下架成功'
    else
      redirect_to :back, alert: '批量下架失败'
    end
  end

  def recommend_all
    if @current_site.ec_products.where(id: params[:ids]).update_all(is_recommend: true)
      redirect_to :back, notice: '批量推荐成功'
    else
      redirect_to :back, alert: '批量推荐失败'
    end
  end

  def not_recommend_all
    if @current_site.ec_products.where(id: params[:ids]).update_all(is_recommend: false)
      redirect_to :back, notice: '批量推荐成功'
    else
      redirect_to :back, alert: '批量推荐失败'
    end
  end

  def delete_all
    if @current_site.ec_products.deleted_all(params[:ids])
      redirect_to :back, notice: '批量删除成功'
    else
      redirect_to :back, alert: '批量删除失败'
    end
  end

  private

    def find_product
      @product = @current_site.ec_products.find(params[:id])
    end
end
