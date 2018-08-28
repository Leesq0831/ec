class AccountMailer < ActionMailer::Base
  default from: "850691579@qq.com"

  def send_mail(subject = "邮件标题", body = "这里是信息")
    res = mail(:to => "18862631811@163.com", :subject => subject, :body => body)
    res.deliver!
  end
end
