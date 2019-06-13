class Api::MiniProgram::MpUsersController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def set_mp_user
    @mp_user = current_account.wx_mp_user
  end

  def new
    callback_redirect_url = bind_callback_api_mini_program_mp_users_url || request.referrer
    bind_params = {
      component_appid: ENVConfig.open_weixin_platform_app_id,
      pre_auth_code: ComponentAppSetting.fetch_pre_auth_code(current_account.wx_mp_user),
      redirect_uri: callback_redirect_url.to_s
    }
    @bind_url = "https://mp.weixin.qq.com/cgi-bin/componentloginpage?#{bind_params.to_query}#wechat_redirect"
    redirect_to @bind_url
  end

  def bind_callback

    mp_user = MpUserSetting.fetch_info_by_auth_code(current_account, params[:auth_code])
    if mp_user
      MiniProgramCommit.add_bind_tester(mp_user)
      redirect_to set_mp_user_api_mini_program_mp_users_path
    else
      logger.error "mp user authorize failed with callback params: #{params.to_json}"
      render plain: "绑定授权失败，请稍候重试..."
    end
  end

end
