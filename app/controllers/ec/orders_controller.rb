class Ec::OrdersController < Ec::BaseController
  before_filter :find_ec_order, only: [:show, :edit, :update, :deliver, :deliver_confirm, :arrived, :completed, :cancel, :refund, :destroy]

  def index
    params[:search] ||= {}
    delivery_type = params[:search].delete(:delivery_type_eq)
    if delivery_type.to_i == 3
      params[:search][:self_pickup_eq] = 1
    elsif [1, 2].include?(delivery_type.to_i)
      params[:search][:self_pickup_eq] = 0
      params[:search][:delivery_type_eq] = delivery_type
    end
    @search = @current_user.ec_orders.search(params[:search])
    @ec_orders = @search.order("created_at desc").page(params[:page])

    params[:search][:delivery_type_eq] = params[:search][:self_pickup_eq] == 1 ? 3 : delivery_type
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @ec_order.update_attributes(params[:ec_order])
      flash[:notice] = '更新成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, alert: '更新失败'
    end
  end

  def deliver
    render layout: 'application_pop'
  end

  def deliver_confirm
    if @ec_order.shipped(params[:logistic_company_id], params[:logistic_no], @ec_order.try(:payment).try(:prepay_id))
      flash[:notice] = '操作成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def arrived
    if @ec_order.arrived!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def completed
    if @ec_order.completed!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def cancel
    if @ec_order.canceled!
      redirect_to :back, notice: '取消成功'
    else
      redirect_to :back, alert: '取消失败'
    end
  end

  def refund
    # if @ec_order.refunded!
    #   redirect_to :back, notice: '取消成功'
    # else
    #   redirect_to :back, alert: '操作失败'
    # end
  end

  def destroy
    if @ec_order.deleted!
      redirect_to :back, notice: "删除成功！"
    else
      redirect_to :back, alert: "删除失败！"
    end
  end

  private
  def find_ec_order
    @ec_order = @current_user.ec_orders.find(params[:id]) rescue nil
    return redirect_to :back, alert: "未找到词订单信息" unless @ec_order
  end
end
