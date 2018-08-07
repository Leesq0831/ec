class AccountMailer < ActionMailer::Base
  default from: "forget_password@winwemedia.com"

  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "标途科技密码找回"
  end
end
