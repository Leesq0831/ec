class Ec::PointRulesController < Ec::BaseController

  def index
    @point_rule = EcPointRule.first_or_create
  end

  def update
    @point_rule = EcPointRule.find(params[:id])
    if @point_rule.update_attributes(params[:ec_point_rule])
      redirect_to ec_point_rules_path, notice: "积分规则修改成功！"
    else
      redirect_to :back, notice: "积分规则修改失败！"
    end
  end
end
