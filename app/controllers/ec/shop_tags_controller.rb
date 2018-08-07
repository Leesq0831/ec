class Ec::ShopTagsController < Ec::BaseController
  before_filter :find_tag, only: [:show, :edit, :update, :destroy]

  def index
    @tags_all = EcTag.shop_tag
    @tags = @tags_all.page(params[:page])
  end

  def new
    @tag = EcTag.new(tag_type: 1)
    render layout: 'application_pop'
  end

  def create
    @tag = EcTag.new(params[:ec_tag].merge(tag_type: 1))
    if @tag.save!
      flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
      else
      redirect_to :back, notice: "添加失败"
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
      redirect_to :back, notice: "添加失败"
    end
  end

  def destroy
    @tag.destroy
    redirect_to ec_shop_tags_path, notice: '保存成功'
  end

  private

    def find_tag
      @tag = EcTag.find(params[:id])
    end
end