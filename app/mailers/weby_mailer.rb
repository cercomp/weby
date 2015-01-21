class WebyMailer < ActionMailer::Base
  default from: "no-reply@ufg.br"

  def confirm_email(user, url)
    @newsletter_user = user
    @newsletter_url = url+"newsletters/confirmation?token="+@newsletter_user.token+":"+@newsletter_user.id.to_s
    mail(to: @newsletter_user.email, subject: t("user_inactive"))
  end
end
