class Ec::LogisticCompaniesController < Ec::BaseController

  before_filter :find_logistic_company, only: [:show,:edit,:update,:destroy]

  def index
    @logistic_companies = EcLogisticCompany.normal.page(params[:page])
  end

  def new
    @logistic_company = EcLogisticCompany.new
    render layout: 'application_pop'
  end

  def create
    @logistic_company = EcLogisticCompany.new(params[:ec_logistic_company])
    if @logistic_company.save
      flash[:notice] = "添加成功！"
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "添加失败"
    end
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @logistic_company.update_attributes(params[:ec_logistic_company])
      flash[:notice] = '更新成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "更新失败"
    end
  end

  def destroy
    if @logistic_company.destroy
      redirect_to ec_logistic_companies_path, notice: "删除成功！"
    else
      redirect_to ec_logistic_companies_path, notice: "删除失败！"
    end
  end

  private
    def find_logistic_company
      @logistic_company = EcLogisticCompany.find(params[:id])
    end
end
