class Api::MiniProgram::WxUsersController < Api::MiniProgram::BaseController
  skip_before_filter :verify_authenticity_token, :set_wx_user

  def create
    #return render json: {openid: WxUser.first.openid, mobile: "123123", name: "测试"}
     if params[:code].present?

      # app_id = params[:app_id]
      code = params[:code].gsub(" ", "+") 
      encrypted_data = params[:encryptedData] ? params[:encryptedData].gsub(" ", "+") : ""
      iv = params[:iv] ? params[:iv].gsub(" ", "+") : ""
    
      url = "https://api.weixin.qq.com/sns/jscode2session?appid=#{@current_mp_user.app_id}&secret=#{@current_mp_user.app_secret}&js_code=#{params[:code]}&grant_type=authorization_code"
      result = RestClient.get(url)
      session[:session_info] = JSON(result)
      encrypt_decrypt_key, openid = session[:session_info].values_at("session_key", "openid")
      wx_user = @current_mp_user.wx_users.where(openid: openid).first_or_create

      if params[:iv]
        wx_middle = MiniProgramEncryptDecrypt.decrypt(encrypted_data, iv, encrypt_decrypt_key)
        nickName, openId, gender, city, province, country, avatarUrl, unionid = wx_middle.values_at("nickName", "openId", "gender", "city", "province", "country", "avatarUrl", "unionid")

        if openId == openid
          begin
            wx_user.update_attributes(
              nickname: nickName,
              sex: gender,
              city: city,
              province: province,
              country: country,
              headimgurl: avatarUrl,
              unionid: unionid
            )
          rescue
          end
        end
      end
      return render json: wx_user.try(:openid) ? {errcode: 200, errmsg: "ok", openid: wx_user.openid} : {errcode: 400, errmsg: "登录失败"}
    end
  end

  def user_info
    @wx_user = @current_wx_user
  end

end
