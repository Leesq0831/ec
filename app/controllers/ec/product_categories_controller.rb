class Ec::ProductCategoriesController < Ec::BaseController
  before_filter :find_category, only: [:show, :edit, :update, :update_sorts, :destroy]

  def index
    @categories_all = @current_user.ec_categories.product_category
    @categories = @categories_all.page(params[:page])
  end

  def new
    @category = @current_user.ec_categories.new(parent_id: params[:parent_id].to_i, category_type: 2)
    render layout: 'application_pop'
  end

  def create
    @category = @current_user.ec_categories.new(params[:ec_category].merge(category_type: 2))
    if @category.save
      flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "添加失败"
    end
  end

  def show
    render layout: 'application_pop'
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @category.update_attributes(params[:ec_category])
      flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "添加失败"
    end
  end

  def destroy
    if @category.ec_products.count > 0 || @category.ec_prices.count > 0
      redirect_to :back,  notice: "菜单下面有商品或价位，不能删除"
    elsif @category.has_children?
      redirect_to :back,  notice: "菜单下面有子菜单，不能删除"
    else
      @category.destroy
      respond_to do |format|
        format.html { redirect_to ec_product_categories_path, notice: "删除成功" }
        format.json { head :no_content }
      end
    end
  end

  private

    def find_category
      @category = @current_user.ec_categories.find(params[:id])
    end
end
