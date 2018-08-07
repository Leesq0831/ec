class Ec::ItemsController < Ec::BaseController
  before_filter :find_item, only: [:show, :update, :destroy]

  def index
    @search = @current_site.ec_items.order('created_at').search(params[:search])
  end

  def show
    render layout: 'application_pop'
  end

  def new
    @item = @current_site.ec_items.new(ec_product_id: params[:ec_product_id])
    render layout: 'application_pop'
  end

  def create
    @item = @current_site.ec_items.new(params[:ec_item])
    if @item.save
      flash[:notice] = '保存成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, alert: '保存失败'
    end
  end

  def update
    if @item.update_attributes(params[:ec_item])
      flash[:notice] = '保存成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, alert: '保存失败'
    end
  end

  def on_shelf
    @item = @current_site.ec_items.find(params[:id])

    respond_to do |format|
      if @item.onshelf!
        format.html { redirect_to :back, notice: '上架成功' }
        format.json { render json: {status_name: @item.status_name} }
      else
        format.html { redirect_to :back, alert: "上架失败:#{@category.errors.full_messages}" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def off_shelf
    @item = @current_site.ec_items.find(params[:id])

    respond_to do |format|
      if @item.offshelf!
        format.html { redirect_to :back, notice: '下架成功' }
        format.json { render json: {status_name: @item.status_name} }
      else
        format.html { redirect_to :back, alert: "下架失败:#{@category.errors.full_messages}" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @item = @current_site.ec_items.find(params[:id])
    @product = @item.ec_product
    if @item.deleted!
      redirect_to (@product.ec_items.show.count > 0 ? :back : ec_shops_path), notice: "删除成功！"
    else
      redirect_to :back, alert: "删除失败！"
    end
  end

  private

    def find_item
      @item = @current_site.ec_items.find(params[:id])
    end
end