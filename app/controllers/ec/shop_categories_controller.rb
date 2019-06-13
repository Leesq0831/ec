class Ec::ShopCategoriesController < Ec::BaseController
  before_filter :find_category, only: [:show, :edit, :update, :update_sorts, :destroy]

  def index
    @categories_all = EcCategory.shop_category
    @categories = @categories_all.page(params[:page]).order(:position)
  end

  def new 
    @category = EcCategory.new(parent_id: params[:parent_id].to_i, category_type: 1)
    render layout: 'application_pop'
  end

  def create
    @category = EcCategory.new(params[:ec_category].merge(category_type: 1))
    if @category.save
      flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "添加失败:#{category.errors.full_messages}"
    end
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

  def update_sorts
    #1:置顶， -1:置底
    if @category.parent
      @categories = @category.parent.children.order(:position)
    else
      @categories = EcCategory.root.order(:position)
    end

    index = @categories.to_a.index(@category)
    @categories.each_with_index{|category, index| category.position = index + 1}

    if params[:type] == "up"

      unless index - 1 >= 0
        render :text => 1
        return
      end

      current_sort = @categories[index].position
      up_sort = @categories[index - 1].position

      @categories[index].position = current_sort - 1
      @categories[index - 1].position = up_sort + 1
    else
      unless @categories[index + 1]
        render :text => -1
        return
      end

      current_sort = @categories[index].position
      down_sort = @categories[index + 1].position

      @categories[index].position = current_sort + 1
      @categories[index + 1].position = down_sort - 1
    end
    @categories.each do |category|
      category.update_column('position', category.position)
    end
    render :partial=> "sub_menu", :collection => @categories.sort{|x, y| x.position<=>y.position}, :as =>:sub_menu
  end

  def destroy
    if @category.ec_shops.count > 0
      redirect_to :back,  notice: "菜单下面有餐厅，不能删除"
    elsif @category.has_children?
      redirect_to :back,  notice: "菜单下面有子菜单，不能删除"
    else
      @category.destroy
      respond_to do |format|
        format.html { redirect_to ec_shop_categories_path,  notice: "删除成功" }
        format.json { head :no_content }
      end
    end
  end

  private

    def find_category
      @category = EcCategory.find(params[:id])
    end
end