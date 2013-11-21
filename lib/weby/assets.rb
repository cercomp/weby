module Weby
  class Assets
    file = 'config/weby.yml'
    if File.exists? file
      settings = YAML.load_file(file)[Rails.env]
      @asset_hosts = settings['asset_host'] if settings
    end

    def self.asset_host_for(source)
      return nil unless @asset_hosts
      @asset_hosts.each do |regex, host|
        return host if source.match(regex)
      end
    end
  end
end