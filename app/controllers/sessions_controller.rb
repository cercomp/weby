class SessionsController < Devise::SessionsController
  layout 'weby_sessions'

  before_filter :set_domain
  before_filter :store_location, only: :new

  private

  def set_domain
    current_domain = request.host.split('.').last(request.session_options[:tld_length].to_i).join('.')
    if Weby::Settings.domain.present? and !(request.domain.match(Weby::Settings.domain))
      current_domain = request.host.gsub(/www\./, '')
    end
    request.session_options[:domain] = ".#{current_domain}"
  end

  def store_location
    session[:return_to] = params[:back_url]
  end
end
