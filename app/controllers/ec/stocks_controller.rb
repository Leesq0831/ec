class Ec::StocksController < Ec::BaseController
  before_filter :find_stock, only: [:show, :edit, :update, :destroy, :effect]

  def index
    @search = @current_site.ec_stock_items.order('created_at desc').search(params[:search])
    @stocks = @search.page(params[:page])
  end

  def new
    @stock = @current_site.ec_stocks.new
    attrs = @current_site.ec_items.onshelf.where(ec_product_id: params[:ids]).all.map{ |item| { ec_item_id: item.id, qty: 100 } }
    @stock.ec_stock_items.build()
    render layout: 'application_pop'
  end

  def create
    @stock = @current_site.ec_stocks.new(params[:ec_stock])
    if @stock.save
      flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
      else
      redirect_to :back, notice: "添加失败"
    end
  end

  def show
    render layout: 'application_pop'
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @stock.update_attributes(params[:ec_stock])
      flash[:notice] = '添加成功'
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, notice: "添加失败"
    end
  end

  def effect
    if @stock.effected!
      redirect_to ec_stocks_path, notice: '入库成功'
    else
      redirect_to ec_stocks_path, alert: '入库失败'
    end
  end

  def destroy
    if @stock.destroy
      redirect_to ec_stocks_path, notice: '删除成功'
    else
      redirect_to ec_stocks_path, alert: '删除失败'
    end
  end

  private

    def find_stock
      @stock = @current_site.ec_stocks.find(params[:id])
    end

end