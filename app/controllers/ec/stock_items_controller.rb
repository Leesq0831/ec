class Ec::StockItemsController < Ec::BaseController
  before_filter :find_stock_item, only: [:show, :edit, :update, :destroy]

  private

    def find_stock_item
      @stock_item = @current_site.ec_stock_items.find(params[:id])
    end

end