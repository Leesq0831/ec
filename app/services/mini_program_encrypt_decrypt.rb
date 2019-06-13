require 'openssl'
require 'base64'

class MiniProgramEncryptDecrypt < ApplicationService
  class << self
    def valid_raw_data_signature(raw_data, signature, encrypt_decrypt_key)
      Digest::SHA1.hexdigest([raw_data, encrypt_decrypt_key].join) == signature
    end

    def decrypt(encrypted_data, iv, encrypt_decrypt_key)
      aes_key = Base64.decode64(encrypt_decrypt_key)
      cipher = OpenSSL::Cipher.new("AES-128-CBC").tap{ |c| c.decrypt }.tap{ |c| c.padding = 0 }.tap{ |c| c.key = aes_key }.tap{ |c| c.iv = Base64.decode64(iv) }
      plain = [cipher.update(Base64.decode64(encrypted_data)), cipher.final].join
      decrypted_data = plain[0...-plain.last.ord]
      SiteLog::Base.logger("mpapi", "MiniProgram decrypt response: #{decrypted_data}")
      JSON.load(decrypted_data)
    end
  end
end
