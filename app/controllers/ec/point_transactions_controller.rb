class Ec::PointTransactionsController < Ec::BaseController
  def index
    @search = PointTransaction.search(params[:search])
    @point_transactions = @search.order("created_at desc").page(params[:page])
  end

  def show
    @point_transaction = PointTransaction.find(params[:id])
  end
end
