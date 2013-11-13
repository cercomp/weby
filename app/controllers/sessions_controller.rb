class SessionsController < Devise::SessionsController
  layout 'weby_sessions'

  before_filter :set_domain

  private

  def set_domain
    current_domain = request.host.split('.').last(request.session_options[:tld_length].to_i).join('.')
    if Weby::Settings.domain.present? and !(request.domain.match(Weby::Settings.domain))
      current_domain = request.host.gsub(/www\./, '')
    end
    request.session_options[:domain] = ".#{current_domain}"
  end
end
