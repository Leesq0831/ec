class Ec::PricesController < Ec::BaseController

  before_filter :find_price, only: [:show,:edit,:update,:destroy]

  def index
    @prices = EcPrice.order("ec_category_id,min_price ").page(params[:page])
  end

  def new
    @price = EcPrice.new
    render layout: 'application_pop'
  end

  def create
    @price = EcPrice.new(params[:ec_price])
    if @price.save
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
    if @price.update_attributes(params[:ec_price])
      flash[:notice] = '更新成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "更新失败"
    end
  end

  def destroy
    if @price.destroy
      redirect_to ec_prices_path, notice: "删除成功！"
    else
      redirect_to ec_prices_path, notice: "删除失败！"
    end
  end

  private
    def find_price
      @price = EcPrice.find(params[:id])
    end
end
