module WeixinMessageEncryptDecrypt
  extend self

  def decrypt(origin_xml="", encrypt_decrypt_key="")
    origin_params = Hash.from_xml(origin_xml)
    WeixinEncryptDecrypt.decrypt(origin_params["xml"]["Encrypt"], encrypt_decrypt_key)
  end

  def encrypt(origin_xml="", encrypt_decrypt_key="", verify_token="", app_id="")
    timestamp = Time.now.to_i.to_s
    nonce = SecureRandom.hex(6)
    encrypted_content = WeixinEncryptDecrypt.encrypt(origin_xml, encrypt_decrypt_key, app_id)
    signature = Digest::SHA1.hexdigest([verify_token, timestamp, nonce, encrypted_content].sort.join)
    "<xml>
      <Encrypt><![CDATA[#{encrypted_content}]]></Encrypt>
      <MsgSignature>#{signature}</MsgSignature>
      <TimeStamp>#{timestamp}</TimeStamp>
      <Nonce>#{nonce}</Nonce>
     </xml>"
  end
end
