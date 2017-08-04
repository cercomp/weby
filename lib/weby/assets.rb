module Weby
  class Assets
    def self.asset_host_for(source, request)
      return nil if !request

      settings = Weby::Settings::AssetHost
      return nil if !(settings.assets_host.present? || settings.uploads_host.present?)
      return nil if request.ssl? && settings.disable_on_https
      return settings.assets_host if source.match(/^\/assets\//) && settings.assets_host.present?
      return settings.uploads_host if source.match(/^\/up\//) && settings.uploads_host.present?
    end

    def self.find_asset path
      # this means compile=true (development)
      if Rails.application.assets
        Rails.application.assets.find_asset(path)
      else
        # in production look in the manifest
        Rails.application.assets_manifest.assets[path]
      end
    end
  end
end
