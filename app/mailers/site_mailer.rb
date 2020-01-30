class SiteMailer < ActionMailer::Base
  def self.site_deactivated(site)
    User.no_admin.local_admin(site).each do |user|
      site_deactivated_user(site, user).deliver_now
    end
  end

  def site_deactivated_user(site, user)
    @site = site
    @user = user
    mail(from: Devise.mailer_sender, to: user.email, subject: "[WEBY] #{t('.site_deactivated')}")
  end
end