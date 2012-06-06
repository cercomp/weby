# Custom Domain Cookie
#
# Set the cookie domain to the custom domain if it's present
class CustomDomainCookie
  def initialize(app)
    @app = app
  end

  def call(env)
    host = env["HTTP_HOST"].split(':').first
    env["rack.session.options"][:domain] = extract_domain(host)
    @app.call(env)
  end

  def extract_domain(host)
    puts Setting.get('tld_length')
  end
end
