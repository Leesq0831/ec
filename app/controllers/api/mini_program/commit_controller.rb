class Api::MiniProgram::CommitController < ApplicationController

  before_filter :find_mp_user

  def get_qrcode
    @image = MiniProgramCommit.get_qrcode("get_qrcode", @mp_user)
    if @image
      render layout: 'application_pop'
    else
      flash[:alert] = '获取二维码失败，请稍后再试。'
      render inline: "<script>parent.location.reload();</script>"
    end
  end

  def submit_audit
    result = MiniProgramCommit.submit_audit("submit_audit", @mp_user)

    if result == "提交成功"
      return redirect_to set_mp_user_api_mini_program_mp_users_path, notice: "提交成功！"
    else
      return redirect_to set_mp_user_api_mini_program_mp_users_path, alert: "#{result}"
    end
  end

  def qrcode
    @image = MiniProgramCommit.qrcode("qrcode", @mp_user)
    if @image
      render layout: 'application_pop'
    else
      flash[:alert] = '获取二维码失败，请稍后再试。'
      render inline: "<script>parent.location.reload();</script>"
    end
  end

  def get_latest_auditstatus
    result = MiniProgramCommit.get_latest_auditstatus("get_latest_auditstatus", @mp_user)
    if result == "审核成功"
      redirect_to :back, notice: "审核成功!"
    elsif result == "审核中"
      redirect_to :back, notice: "审核中!"
    elsif result == "网络有问题，请稍后再试！"
      redirect_to :back, notice: "网络有问题，请稍后再试！"
    else
      redirect_to :back, alert: "#{result}"
    end
  end

  private

    def find_mp_user
      @mp_user = current_site.wx_mp_user
    end

end
