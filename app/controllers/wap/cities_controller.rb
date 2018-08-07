class Wap::CitiesController < ActionController::Base
  def index
    @cities = City.where(province_id: params[:province_id])

    respond_to do |format|
      format.json { render json: {data: @cities, code: 1} }
    end
  end
end
