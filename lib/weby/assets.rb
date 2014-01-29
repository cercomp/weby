module Weby
  class Assets
    file = 'lib/weby/config/asset_host.yml'
    if File.exists? file
      settings = YAML.load_file(file)[Rails.env]
      if settings
        @asset_hosts = settings['hosts']
        @disable_on_https = settings['disable_on_https']
      end
    end

    def self.asset_host_for(source, request)
      return nil if !@asset_hosts || !request
      return nil if request.ssl? && @disable_on_https
      @asset_hosts.each do |regex, host|
        return host if source.match(regex)
      end
    end
  end
end