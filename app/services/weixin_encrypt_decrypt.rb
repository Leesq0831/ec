module WeixinEncryptDecrypt
  extend self

  def decrypt(encryped_content="", encrypt_decrypt_key="")
    decrypted_content = aes_decrypt(encryped_content, encrypt_decrypt_key)
    return decrypted_content[20..decrypted_content.rindex('>')]
  end

  def encrypt(origin_content="", encrypt_decrypt_key="", app_id="")
    msg = origin_content.force_encoding("ascii-8bit")
    msg = kcs7_encoder "#{SecureRandom.hex(8)}#{[msg.size].pack('N')}#{msg}#{app_id}"
    aes_encrypt(msg, encrypt_decrypt_key)
  end

  private
  def kcs7_encoder(msg)
    block_size = 32
    amount_to_pad = block_size - (msg.length % block_size)
    amount_to_pad = block_size if amount_to_pad == 0
    pad = amount_to_pad.chr
    "#{msg}#{pad * amount_to_pad}"
  end

  def aes_decrypt(msg, encrypt_decrypt_key)
    aes_key = Base64.decode64 encrypt_decrypt_key.to_s + "="
    cipher = OpenSSL::Cipher.new('AES-256-CBC')
      .tap{|c| c.decrypt }
      .tap{|c| c.padding = 0 }
      .tap{|c| c.key = aes_key }
      .tap{|c| c.iv = aes_key[0, 16] }
    cipher.update(Base64.decode64(msg.strip)).strip
  end

  def aes_encrypt(msg, encrypt_decrypt_key)
    aes_key           = Base64.decode64(encrypt_decrypt_key + '=')
    en_cipher         = OpenSSL::Cipher.new('AES-256-CBC')
      .tap{|c| c.encrypt }
      .tap{|c| c.padding = 0 }
      .tap{|c| c.key = aes_key }
      .tap{|c| c.iv = aes_key[0, 16] }
    Base64.encode64("#{en_cipher.update(msg)}#{en_cipher.final}")
  end
end
