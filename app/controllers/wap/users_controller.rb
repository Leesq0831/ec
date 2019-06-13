class Wap::UsersController < Wap::BaseController

  def update
    if @user.update_attributes(params[:user])
      render json: {data: @order, code: 1}
    else
      render json: {data: @order, code: 0}
    end
  end

  def set_mobile
    if @user.update_attributes(mobile: params[:mobile])
      render json: {data: @order, code: 1}
    else
      render json: {data: @order, code: 0}
    end
  end

  def report_location
    if @user.wx_user.update_attributes(location_x: params[:longitude], location_y: params[:latitude])
      render json: {code: 1}
    else
      render json: {code: 0}
    end
  end

end
