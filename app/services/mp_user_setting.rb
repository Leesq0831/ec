module MpUserSetting
  extend self

  def fetch_info_by_auth_code(site,auth_code)
    mp_user = auth_code.present? ? fetch_access_token_by_auth_code(site, auth_code) : nil
    fetch_mp_user_info(mp_user) if mp_user
    return mp_user
  end

  def fetch_access_token(mp_user)
    renew_access_token(mp_user)
  end

  private
    def fetch_access_token_by_auth_code(site, auth_code)
      request_params = { component_appid: ENVConfig.open_weixin_platform_app_id, authorization_code: auth_code }.to_json

      mp_user = site.nil? ? WxMpUser.where(nickname: "mpqinyetest001").first : site.wx_mp_user

      resp = HTTParty.post("https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token=#{ComponentAppSetting.fetch_access_token(mp_user)}", body: request_params)
      SiteLog::Base.logger("mpapi", "MpUserSetting fetch_access_token_by_auth_code(#{auth_code}) response: #{resp.body}")
      resp_info = JSON.parse(resp.body)
      if resp_info["errcode"].to_i.zero?
        authorization_info = resp_info["authorization_info"]
        mp_user.update_attributes(app_id: authorization_info["authorizer_appid"], access_token: authorization_info["authorizer_access_token"], refresh_token: authorization_info["authorizer_refresh_token"], expires_in: (Time.now + (authorization_info["expires_in"].to_i.seconds - 5.minutes)).to_s)
        return mp_user
      end
    end

    def fetch_mp_user_info(mp_user)
      request_params = { component_appid: ENVConfig.open_weixin_platform_app_id, authorizer_appid: mp_user.app_id }.to_json
      resp = HTTParty.post("https://api.weixin.qq.com/cgi-bin/component/api_get_authorizer_info?component_access_token=#{ComponentAppSetting.fetch_access_token(mp_user)}", body: request_params)
      SiteLog::Base.logger("mpapi", "MpUserSetting fetch_mp_user_info(#{mp_user.app_id}): #{resp.body}")

      resp_info = JSON.parse(resp.body)
      if resp_info["errcode"].to_i.zero?
        authorizer_info = resp_info["authorizer_info"]
        authorization_info = resp_info["authorization_info"]
        mp_user.update_attributes!(
          openid: authorizer_info["user_name"],
          nickname: authorizer_info["nick_name"],
          head_img: authorizer_info["head_img"],
          qrcode_url: authorizer_info["qrcode_url"],
          alias: authorizer_info["alias"],
          principal_name: authorizer_info["principal_name"],
          signature: authorizer_info["signature"],
          mini_program_info: resp_info,
          func_info: authorization_info["func_info"]
        )
      end
    end

    def renew_access_token(mp_user)
      request_params = {
        component_appid: ENVConfig.open_weixin_platform_app_id,
        authorizer_appid: mp_user.app_id,
        authorizer_refresh_token: mp_user.refresh_token
      }.to_json
      resp = HTTParty.post("https://api.weixin.qq.com/cgi-bin/component/api_authorizer_token?component_access_token=#{ComponentAppSetting.fetch_access_token(mp_user)}", body: request_params)
      SiteLog::Base.logger("mpapi", "MpUserSetting renew_access_token(#{mp_user.app_id}) response: #{resp.body}")

      resp_info = JSON.parse(resp.body)
      if resp_info["errcode"].to_i.zero? && resp_info["authorizer_refresh_token"].present? && resp_info["authorizer_access_token"].present?
        mp_user.update_attributes(access_token: resp_info["authorizer_access_token"], refresh_token: resp_info["authorizer_refresh_token"], expires_in: (Time.now + (resp_info["expires_in"].to_i.seconds - 5.minutes)).to_s)
        return resp_info["authorizer_access_token"]
      end
    end

end
