class Api::MiniProgram::MessagesController < Api::MiniProgram::BaseController
  InvalidMessageSignatureError = Class.new StandardError
  skip_before_filter :set_wx_mp_user,:set_wx_user

  before_filter :set_parsed_params, :verify_message_signature, only: [:authorize_events, :receive]
  before_filter :check_signature!, only: :service

  ##first
  def authorize_events
    if @parsed_params["xml"]["InfoType"] == "component_verify_ticket"
      @mp_user = WxMpUser.first
      @mp_user.update_attributes(mp_ticket: @parsed_params["xml"]["ComponentVerifyTicket"]) if @mp_user
    end
    return render json: "success"
  end

  def receive
    if @parsed_params["xml"]["MsgType"] == "text" && @parsed_params["xml"]["Content"] =~ /QUERY_AUTH_CODE/
      auth_code = @parsed_params["xml"]["Content"].split(":").last
      mp_user = MpUserSetting.fetch_info_by_auth_code(nil, auth_code)
      request_params = { touser: @parsed_params["xml"]["FromUserName"], msgtype: "text", text: {content: "#{auth_code}_from_api"} }.to_json
      resp = HTTParty.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{MpUserSetting.fetch_access_token(mp_user)}", body: request_params )
      Rails.logger.info "custom service response: #{resp.body}"
      return ""
    elsif @parsed_params["xml"]["Content"] == "TESTCOMPONENT_MSG_TYPE_TEXT"
      plain_xml = "<xml>
        <ToUserName><![CDATA[#{@parsed_params['xml']['FromUserName']}]]></ToUserName>
        <FromUserName><![CDATA[#{@parsed_params['xml']['ToUserName']}]]></FromUserName>
        <CreateTime>#{Time.now.to_i}</CreateTime>
        <MsgType><![CDATA[text]]></MsgType>
        <Content><![CDATA[TESTCOMPONENT_MSG_TYPE_TEXT_callback]]></Content>
      </xml>"
      render_encrypted_weixin_message(plain_xml)
    elsif @parsed_params["xml"]["MsgType"] == "event"  && @parsed_params["xml"]["Event"]  == "LOCATION"
      plain_xml = "<xml>
        <ToUserName><![CDATA[#{@parsed_params['xml']['FromUserName']}]]></ToUserName>
        <FromUserName><![CDATA[#{@parsed_params['xml']['ToUserName']}]]></FromUserName>
        <CreateTime>#{Time.now.to_i}</CreateTime>
        <MsgType><![CDATA[text]]></MsgType>
        <Content><![CDATA[#{@parsed_params['xml']['Event']}from_callback]]></Content>
      </xml>"
      render_encrypted_weixin_message(plain_xml)
    elsif @parsed_params["xml"]["MsgType"] == "event"  && @parsed_params["xml"]["Event"]  == "weapp_audit_success"
      @mp_user = WxMpUser.where(openid: @parsed_params["xml"]["ToUserName"]).first
      if @mp_user
        @mp_user.update_attributes(auditstatus: 1)
        MiniProgramCommit.release("release", @mp_user)
      end
      return render json: "success"
    elsif @parsed_params["xml"]["MsgType"] == "event"  && @parsed_params["xml"]["Event"]  == "weapp_audit_fail"
      @mp_user = WxMpUser.where(openid: @parsed_params["xml"]["ToUserName"]).first
      @mp_user.update_attributes(auditstatus: -1, fail_reason: @parsed_params["xml"]["Reason"]) if @mp_user
      return render json: "success"
    else
      return render json: "success"
    end
  end

  def service
    if @checked
      if params[:echostr]
        return render xml: params[:echostr]
      else
        set_parsed_params
        verify_message_signature
        plain_xml = "<xml>
          <ToUserName><![CDATA[#{@parsed_params['xml']['ToUserName']}]]></ToUserName>
          <FromUserName><![CDATA[wxb0019efef2ec5765]]></FromUserName>
          <CreateTime>#{Time.now.to_i}</CreateTime>
          <MsgType><![CDATA[transfer_customer_service]]></MsgType>
        </xml>"
        return render xml: plain_xml
      end
    end
  end

  private

    def set_parsed_params
      key = ENVConfig.weixin_message_encrypt_decrypt_key
      request_body = request.body.tap{|b| b.rewind }.read
      decrypted_xml = WeixinMessageEncryptDecrypt.decrypt(request_body, ENVConfig.weixin_message_encrypt_decrypt_key)
      Rails.logger.info "weixin message request decrypted xml:\n#{decrypted_xml}"
      @origin_params = Hash.from_xml request_body
      @parsed_params = Hash.from_xml decrypted_xml
    end

    def verify_message_signature
      encrypted_content = @origin_params["xml"]["Encrypt"]
      raise InvalidMessageSignatureError unless Digest::SHA1.hexdigest([ENVConfig.weixin_message_verify_token, params[:timestamp], params[:nonce], encrypted_content].sort.join).eql?(params[:msg_signature])
    end

    def render_encrypted_weixin_message(plain_xml)
      if plain_xml.present?
        render xml: WeixinMessageEncryptDecrypt.encrypt(plain_xml, ENVConfig.weixin_message_encrypt_decrypt_key, ENVConfig.weixin_message_verify_token, ENVConfig.open_weixin_platform_app_id)
      else
        ""
      end
      Rails.logger.info "encrypted reply xml:\n#{response.body}"
    end

    def check_signature!
      Rails.logger.info "********check_sinature:#{params}"
      return render text: '请求参数不正确' if params[:app_id].blank?
      @mp_user = WxMpUser.find_by_app_id(params[:app_id].to_s)
      return @checked = false unless @mp_user
      token = "399033f89a0859330eaz"
      @checked = params[:signature] == Digest::SHA1.hexdigest([token, params[:timestamp], params[:nonce]].map!(&:to_s).sort.join)
    end

end
