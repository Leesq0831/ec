class Ec::CommentTemplatesController < Ec::BaseController
  before_filter :find_comment_template, only: [:show,:edit,:update,:destroy]

  def index
    @search = EcCommentTemplate.search(params[:search])
    @comment_templates = @search.page(params[:page])
  end

  def new
    @comment_template = EcCommentTemplate.new
    render layout: 'application_pop'
  end

  def create
    @comment_template = EcCommentTemplate.new(params[:ec_comment_template])
    if @comment_template.save
      flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "添加失败: #{@comment_template.errors.full_messages.join(',')}"
    end
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @comment_template.update_attributes(params[:ec_comment_template])
      flash[:notice] = '更新成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "更新失败: #{@comment_template.errors.full_messages.join(',')}"
    end
  end

  def destroy
    @comment_template.deleted!
    redirect_to ec_comment_templates_path, notice: "删除成功！"
  end

  private
    def find_comment_template
      @comment_template = EcCommentTemplate.find(params[:id])
    end
end
