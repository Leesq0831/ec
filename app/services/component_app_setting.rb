module ComponentAppSetting
  extend self

  def fetch_pre_auth_code(mp_user)
    create_pre_auth_code(mp_user)
  end

  def fetch_access_token(mp_user)
    renew_access_token(mp_user)
  end

  private
    def renew_access_token(mp_user)
      request_params = {
        component_appid: ENVConfig.open_weixin_platform_app_id,
        component_appsecret: ENVConfig.open_weixin_platform_app_secret,
        component_verify_ticket: WxMpUser.first.mp_ticket
        # component_verify_ticket: Rails.cache.read("component_verify_ticket")
      }.to_json

      resp = HTTParty.post("https://api.weixin.qq.com/cgi-bin/component/api_component_token", body: request_params)
      SiteLog::Base.logger("mpapi", "ComponentAppSetting renew_access_token response: #{resp.body}")
      resp_info = JSON.parse(resp.body)
      if resp_info['errcode'].to_i.zero?
        return resp_info["component_access_token"]
      end
    end

    def create_pre_auth_code(mp_user)
      request_params = { component_appid: ENVConfig.open_weixin_platform_app_id }.to_json
      resp = HTTParty.post("https://api.weixin.qq.com/cgi-bin/component/api_create_preauthcode?component_access_token=#{fetch_access_token(mp_user)}", body: request_params)
      SiteLog::Base.logger("mpapi", "ComponentAppSetting create_pre_auth_code response: #{resp.body}")
      resp_info = JSON.parse(resp.body)
      if resp_info['errcode'].to_i.zero?
        return resp_info["pre_auth_code"]
      end
    end

end
