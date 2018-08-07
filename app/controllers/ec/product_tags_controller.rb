class Ec::ProductTagsController < Ec::BaseController
  before_filter :find_tag, only: [:show, :edit, :update, :destroy]

  def index
    @tags_all = @current_site.ec_tags.product_tag
    @tags = @tags_all.page(params[:page])
  end

  def new
    @tag = @current_site.ec_tags.new(tag_type: 2)
    render layout: 'application_pop'
  end

  def create
    @tag = @current_site.ec_tags.new(params[:ec_tag].merge(tag_type: 2))
    if @tag.save
      flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "添加失败: #{@tag.errors.full_messages.join(',')}"
    end
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @tag.update_attributes(params[:ec_tag])
      flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "添加失败: #{@tag.errors.full_messages.join(',')}"
    end
  end

  def destroy
    @tag.destroy
    redirect_to ec_product_tags_path, notice: '保存成功'
  end

  private

    def find_tag
      @tag = @current_site.ec_tags.find(params[:id])
    end
end