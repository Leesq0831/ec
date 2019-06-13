class MiniProgramSessionService < MiniProgramBaseService

  def self.code2session(code, appid)
    request_params = {
      appid: appid,
      js_code: code,
      grant_type: "authorization_code",
      component_appid: ENVConfig.open_weixin_platform_app_id,
      component_access_token: ComponentAppSetting.fetch_access_token(WxMpUser.where(app_id: appid).first)
    }
    logger.info "MiniProgram create session request with: #{request_params.to_query}"
    conn = Faraday.new("https://api.weixin.qq.com/sns/component/jscode2session?#{request_params.to_query}", { ssl: { verify: false } })
    resp = conn.get
    SiteLog::Base.logger("mpapi", "MiniProgram code2session response: #{resp.body}")
    JSON.load(resp.body)
  end

end
