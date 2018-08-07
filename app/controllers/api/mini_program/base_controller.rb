class Api::MiniProgram::BaseController < ActionController::Base
  # include AuthGuard
  # include UrlUtility

  before_filter :set_wx_mp_user, :set_wx_user

  private
    def set_wx_user
      @current_wx_user = @current_mp_user.wx_users.where(openid: params[:openid]).first
      return @current_wx_user = nil unless @current_wx_user
      @current_user = @current_wx_user.user
      return @current_user = nil unless @current_user
      #raise ActiveRecord::RecordNotFound unless @current_user.present?
    end

    def set_wx_mp_user
      @current_mp_user = WxMpUser.where(app_id: params[:app_id]).first
      raise ActiveRecord::RecordNotFound unless @current_mp_user
      set_current_account
    end

    def set_current_account
      @current_account = @current_mp_user.try(:account)
      raise ActiveRecord::RecordNotFound unless @current_site
    end

end
