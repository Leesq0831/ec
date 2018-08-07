class Wap::PricesController < ActionController::Base
  def index
    @prices = EcPrice.where(ec_category_id: params[:ec_category_id]).order("min_price asc")

    respond_to do |format|
      format.json { render json: {data: @prices, code: 1} }
    end
  end
end
