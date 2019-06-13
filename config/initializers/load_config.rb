# 常用变量声明
MOBILE_SUB_DOMAIN = Settings.mhostname.sub(/\.(com|dev).?/, '').split('.')[0..-2].join('.')

EXPORTING_COUNT = 2000

# kefu
KEFU_URL = Rails.env.production? ? "http://kf.winwemedia.com" : "http://kefu.winwemedia.com"

if File.exists?("#{Rails.root}/config/payment_config.yml")
  PAYMENT_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/payment_config.yml")[Rails.env] || {})
end

ENV_CONFIG = YAML.load_file(File.join(Rails.root, 'config', 'local_env.yml'))[Rails.env] || {} rescue {}

class ENVConfig
  ENV_CONFIG.each do |key, value|
    const_set key.upcase, value
  end

  class << self
    ENV_CONFIG.each do |key, value|
      define_method(key.to_sym) { value }
    end

    def method_missing(method_sym, *arguments, &block)
      nil
    end
  end
end

if ENVConfig.qiniu_access_key.present?
  Qiniu.establish_connection!(access_key: ENVConfig.qiniu_access_key, secret_key: ENVConfig.qiniu_secret_key)
end
