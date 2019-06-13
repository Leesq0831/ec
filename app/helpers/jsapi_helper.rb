module JsapiHelper
  def setup_jsapi
    @wx_mp_user = WxMpUser.first
    return if @wx_mp_user.nil?

    @appid = @wx_mp_user.app_id
    @timestamp = Time.now.to_i.to_s
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    @noncestr = (0...16).map { o[rand(o.length)] }.join
    @jsapi_ticket = @wx_mp_user.get_wx_jsapi_ticket
    @string = ["jsapi_ticket=#{@jsapi_ticket}", "noncestr=#{@noncestr}", "timestamp=#{@timestamp}", "url=#{request.url.split('#').first}"].sort.join('&')

    @signature = Digest::SHA1.hexdigest @string
  end
end