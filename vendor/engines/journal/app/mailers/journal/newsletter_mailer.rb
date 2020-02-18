module Journal
  class NewsletterMailer < ActionMailer::Base
    helper ::RepositoryHelper

    def confirm_email(user, url)
      @newsletter_user = user
      @newsletter_url = url+(url[url.length-1]=="/" ? "" : "/")+"newsletters/confirmation?token="+@newsletter_user.token+":"+@newsletter_user.id.to_s
      mail(from: Devise.mailer_sender, to: @newsletter_user.email, subject: t("user_inactive"))
    end

    def news_email(from, to, subject, site, news)
      @site = site
      @url = site.url + (site.url[site.url.length-1]=="/" ? "" : "/") + "newsletters/new?opt=delete"
      @news = news
      mail(from: from, bcc: to, subject: subject)
    end

    def delete_email(from, user, url)
      @newsletter_user = user
      @newsletter_delete_url = url+(url[url.length-1]=="/" ? "" : "/")+"newsletters/getout?token="+@newsletter_user.token+":"+@newsletter_user.id.to_s
      mail(from: from, to: @newsletter_user.email, subject: t("user_inactive"))
    end
  end
end
