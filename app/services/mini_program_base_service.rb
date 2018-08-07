class MiniProgramBaseService < ApplicationService
  attr_reader :wx_user

  def initialize(wx_user)
    @wx_user = wx_user
  end

  private
    def mini_program_api_url(action)
      "https://api.weixin.qq.com/wxa/#{action}?access_token=#{MpUserSetting.fetch_access_token(mp_user)}"
    end
end
