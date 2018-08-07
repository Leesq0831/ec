class Ec::LogisticTemplatesController < Ec::BaseController

  before_filter :set_logistic_template, only: [:update, :edit, :destroy]

  # before_filter do
  #   @partialLeftNav = "/layouts/partialLeftSys"
  # end

  # add_breadcrumb "商城设置", "#nogo", options: {}
  # add_breadcrumb "物流设置", :admin_logistic_templates_path

  def index
    params_q = params[:q].present? ? params[:q] : nil
    @q = @current_site.ec_logistic_templates.includes([:ec_logistic_template_items]).order('ec_logistic_templates.created_at DESC').search(params_q)
    @logistic_templates = @q.page(params[:page])
  end

  def new
    @logistic_template = @current_site.ec_logistic_templates.new(valuation_method: 'weight', ship_method_list: '快递')
    @logistic_template.ec_logistic_template_items << @logistic_template.ec_logistic_template_items.new(first_unit: 1, add_unit: 1, is_default: 1, city_list: '全国')
  end

  def create
    @logistic_template = @current_site.ec_logistic_templates.new(params[:ec_logistic_template])
    if @logistic_template.save
      redirect_to ec_logistic_templates_path, notice: '添加成功'
    else
      flash[:alert] = '添加失败'
      render action: 'new'
    end
  end

  def update
    data_process
    if @logistic_template.update_attributes(params[:ec_logistic_template])
      redirect_to ec_logistic_templates_path, notice: '更新成功'
    else
      flash[:alert] = '更新失败'
      render action: 'edit'
    end
  end

  def destroy
    if @logistic_template.try(:destroy)
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: '删除失败'
    end
  end

  def data_process
    params[:ec_logistic_template][:ec_logistic_template_items_attributes].each do |k, v|
      if v[:id].present? && v[:_destroy].to_i == 0
        lti = @logistic_template.ec_logistic_template_items.where(id: v[:id]).first
        lti.city_list = v[:cities_str]
        lti.save
      end
    end
  end

  private
    def set_logistic_template
      @logistic_template = @current_site.ec_logistic_templates.includes([:ec_logistic_template_items]).where(id: params[:id]).first
    end
end
