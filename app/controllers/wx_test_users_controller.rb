class WxTestUsersController < ApplicationController

  before_filter :find_mp_user, only: [:create, :destroy]
  before_filter :find_wx_test_user, only: [:destroy]

  def new
    @wx_test_user = @current_site.wx_test_users.new
    render layout: 'application_pop'
  end

  def create
    if @current_site.wx_test_users.where(wx_id: params[:wx_test_user][:wx_id]).first
      redirect_to :back, notice: "该用户已经是体验者，请输入其他微信号"
    else
      @wx_test_user = @current_site.wx_test_users.new(params[:wx_test_user])
      if @wx_test_user.save
        result = MiniProgramCommit.bind_tester(@wx_test_user.wx_id, "bind_tester", @mp_user)
        if result == "绑定体验者成功"
          flash[:notice] = '绑定体验者成功'
          render inline: "<script>parent.location.reload();</script>"
        else
          @wx_test_user.destroy
          redirect_to :back, alert: "#{result}"
        end
      else
        redirect_to :back, notice: "绑定体验者失败"
      end
    end
  end

  def destroy
    result = MiniProgramCommit.bind_tester(@wx_test_user.wx_id, "unbind_tester", @mp_user)
    if result == "解绑体验者成功"
      @wx_test_user.destroy
      redirect_to :back, notice: "解绑体验者成功!"
    else
      redirect_to :back, alert: "#{result}"
    end
  end

  private

    def find_mp_user
      @mp_user = @current_site.wx_mp_user
    end

    def find_wx_test_user
      @wx_test_user = @current_site.wx_test_users.find(params[:id])
    end

end
