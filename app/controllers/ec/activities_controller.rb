class Ec::ActivitiesController < Ec::BaseController
  before_filter :find_activity, only: [:show, :edit, :update, :destroy, :stop, :start]

  def index
    @activities = EcActivity.page(params[:page])
  end

  def subscribe
    @activity = EcActivity.subscribe.first || EcActivity.create(name: '关注活动', activity_type: 1, title: '关注活动标题', summary: '关注活动摘要')
  end

  def new
    @activity = EcActivity.new
    render layout: 'application_pop'
  end

  def create
    @activity = EcActivity.new(params[:ec_activity].merge(activity_type: params[:type] || 1))
    if @activity.save
      flash[:notice] = "保存成功！"
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, alert: "保存失败, #{@activity.errors.full_messages}"
    end
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @activity.update_attributes(params[:ec_activity])
      # flash[:notice] = '更新成功'
      # render inline: "<script>parent.location.reload();</script>"
      redirect_to :back, notice: "保存成功"
    else
      redirect_to :back, alert: "更新失败, #{@activity.errors.full_messages}"
    end
  end

  def stop
    @activity.stopped!
    redirect_to :back, notice: '操作成功'
  end

  def start
    @activity.start!
    redirect_to :back, notice: '操作成功'
  end

  def destroy
    if @activity.destroy
      redirect_to ec_activities_path, notice: "删除成功！"
    else
      redirect_to ec_activities_path, alert: "删除失败！"
    end
  end

  private
    def find_activity
      @activity = EcActivity.find(params[:id])
    end
end
