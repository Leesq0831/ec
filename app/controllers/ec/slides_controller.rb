class Ec::SlidesController < Ec::BaseController
  before_filter :set_ec_slide, only: [:edit, :update, :destroy]

  # before_filter do
  #   @partialLeftNav = "/layouts/partialLeftSys"
  # end

  def index
    @ec_slides = @current_user.ec_slides.order(:position)
    @ec_slide = @current_user.ec_slides.where(id: params[:id]).first || @current_user.ec_slides.new
  end

  def new
    @ec_slide = @current_user.ec_slides.new(slide_type: params[:slide_type] || 1, position: params[:position] || 1)
    render layout: 'application_pop'
  end

  def create
    @ec_slide = @current_user.ec_slides.new(params[:ec_slide])
    if @ec_slide.save
      flash[:notice] = "添加成功"
      render inline: "<script>window.parent.location.href = '#{ec_slides_path}';</script>"
    else
      flash[:notice] = "添加失败"
      render action: 'new', layout: 'application_pop'
    end
  end

  def edit
    render layout: 'application_pop'
  end

  def cleanup
    if EcSlideUser.destroy_all
      redirect_to ec_slides_path, notice: '清空缓存成功!'
    else
      redirect_to ec_slides_path, notice: '清空缓存失败!'
    end
  end

  def update
    if @ec_slide.update_attributes(params[:ec_slide])
      flash[:notice] = "更新成功"
      render inline: "<script>window.parent.location.href = '#{ec_slides_path}';</script>"
    else
      flash[:notice] = "更新失败"
      render action: 'edit', layout: 'application_pop'
    end
  end

  def destroy
    if @ec_slide.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: '删除失败'
    end
  end

  private

  def set_ec_slide
    @ec_slide = @current_user.ec_slides.where(id: params[:id]).first
    return redirect_to ec_slides_path, alert: '图片不存在或已删除' unless @ec_slide
  end

end
