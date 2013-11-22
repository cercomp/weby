module Weby
  class Assets
    file = 'config/weby.yml'
    if File.exists? file
      settings = YAML.load_file(file)[Rails.env]
      if settings
        @asset_hosts = settings['asset_host']
        @asset_host_https = settings['asset_host_https'].nil? ? true : settings['asset_host_https']
      end
    end

    def self.asset_host_for(source, request)
      return nil if request.ssl? && !@asset_host_https
      return nil unless @asset_hosts
      @asset_hosts.each do |regex, host|
        return host if source.match(regex)
      end
    end
  end
end