class Ec::DiningTimesController < Ec::BaseController
  before_filter :find_dining_time, only: [:edit, :update,:destroy]
  def index
    @ec_dining_times = EcDiningTime.order("start_at asc").page(params[:page])
  end

  def new
    @ec_dining_time = EcDiningTime.new
    render layout: 'application_pop'
  end

  def create
    @ec_dining_time = EcDiningTime.new(params[:ec_dining_time])
    if @ec_dining_time.save
      flash[:notice] = "添加成功！"
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "添加失败: #{@ec_dining_time.errors.full_messages.join(',')}"
    end
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @ec_dining_time.update_attributes(params[:ec_dining_time])
      flash[:notice] = '更新成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "更新失败: #{@ec_dining_time.errors.full_messages.join(',')}"
    end
  end

  def destroy
    if @ec_dining_time.destroy
      redirect_to ec_dining_times_path, notice: "删除成功！"
    else
      redirect_to ec_dining_times_path, notice: "删除失败！"
    end

  end

  private
    def find_dining_time
      @ec_dining_time = EcDiningTime.find(params[:id])
    end
end
