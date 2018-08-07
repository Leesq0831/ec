class Ec::OrderRulesController < Ec::BaseController

  def index
    @order_rule = @current_site.ec_order_rules.first_or_create(is_auto_confirm:true)
  end

  def update
    @order_rule = @current_site.ec_order_rules.find(params[:id])
    if @order_rule.update_attributes(params[:ec_order_rule])
      redirect_to ec_order_rules_path, notice: "订单设置修改成功！"
    else
      redirect_to :back, notice: "订单设置修改失败！"
    end
  end
end
