class Wap::ActivitiesController < Wap::BaseController

  def show
    @activity = EcActivity.where(id: params[:id].to_i).first
    @user.ec_user_activities.where(ec_activity_id: @activity.id).first_or_create if @activity.present?

    redirect_to wap_cart_items_path
  end

end
