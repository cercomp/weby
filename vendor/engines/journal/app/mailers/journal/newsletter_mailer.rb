module Journal
  class NewsletterMailer < ActionMailer::Base
    helper ::RepositoryHelper
    helper :application

    def confirm_email(user, site)
      @newsletter_user = user
      @newsletter_url = newsletter_url('confirmation', token: "#{@newsletter_user.token}:#{@newsletter_user.id}", subdomain: site)
      mail(from: Devise.mailer_sender, to: @newsletter_user.email, subject: t("user_inactive"))
    end

    def news_email(from, to, subject, site, news)
      @site = site
      @optout_url = new_newsletter_url(opt: 'delete', subdomain: site)
      @news = news
      @extension = @site.extensions.find_by(name: 'journal')
      mail(from: from, bcc: to, subject: subject)
    end

    def delete_email(from, user, site)
      @newsletter_user = user
      @newsletter_delete_url = newsletter_url('getout', token: "#{@newsletter_user.token}:#{@newsletter_user.id}", subdomain: site)
      mail(from: from, to: @newsletter_user.email, subject: t("user_inactive"))
    end
  end
end
