class Api::MiniProgram::SessionsController < Api::MiniProgram::BaseController
  skip_before_filter :set_wx_user
	
  # before_filter :set_wx_user
  # before_filter :set_session_token, :set_session_info, only: [:session_info, :user_info, :decrypted_info]

  # def create
  #   session_info = MiniProgramSessionService.new(@wx_user).code2session(params[:code])
  #   if session_info["errcode"].present?
  #     render json: session_info, status: :unprocessable_entity
  #   else
  #     session_token = [@wx_user.app_id, "session", SecureRandom.base58(32)].join("-").tap{ |t| Rails.cache.write(t, session_info, expires_in: 20.days) }
  #     render json: session_info.slice("openid", "unionid").merge(token: session_token), status: :created
  #   end
  # end

  # def session_info
  #   render json: @session_info
  # end

  # def user_info
  #   raw_data, signature, encrypted_data, iv = params.values_at(:raw_data, :signature, :encrypted_data, :iv)
  #   encrypt_decrypt_key = @session_info["session_key"]
  #   if MiniProgramEncryptDecrypt.valid_raw_data_signature(raw_data, signature, encrypt_decrypt_key)
  #     render json: MiniProgramEncryptDecrypt.decrypt(encrypted_data, iv, encrypt_decrypt_key), status: :ok
  #   else
  #     render json: {error: {message: "Invalid signature"}}, status: :unprocessable_entity
  #   end
  # end

  # def decrypted_info
  #   encrypted_data, iv = params.values_at(:encrypted_data, :iv)
  #   encrypt_decrypt_key = @session_info["session_key"]
  #   render json: MiniProgramEncryptDecrypt.decrypt(encrypted_data, iv, encrypt_decrypt_key), status: :ok
  # end

  # private
  #   def set_wx_user
  #     @wx_user = WxUser.find_by(openid: params[:openid])
  #     raise ActiveRecord::RecordNotFound unless @wx_user.present?
  #   end

  #   def set_session_token
  #     auth_type, auth_value = request.authorization&.split
  #     @session_token = (auth_type.eql?("PlainSessionToken") && auth_value.present?) ? auth_value : nil
  #   end

  #   def set_session_info
  #     @session_info = @session_token.present? ? Rails.cache.read(@session_token) : {}
  #   end
end
