module Journal
  class NewsletterMailer < ActionMailer::Base
    helper ::RepositoryHelper

    def confirm_email(user, url)
      @newsletter_user = user
      @newsletter_url = url+"/newsletters/confirmation?token="+@newsletter_user.token+":"+@newsletter_user.id.to_s
      mail(from: "no-reply@ufg.br", to: @newsletter_user.email, subject: t("user_inactive"))
    end

    def news_email(from, to, subject, site, news)
      @site = site
      @news = news
      mail(from: from, cco: to, subject: subject)
    end
  end
end
