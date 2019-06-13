class Wap::DistrictsController < ActionController::Base
  def index
    @districts = District.where(city_id: params[:city_id])

    respond_to do |format|
      format.json { render json: {data: @districts, code: 1} }
    end
  end
end
