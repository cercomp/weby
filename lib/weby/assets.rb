module Weby
  class Assets
    def self.asset_host_for(source, request)
      return nil if !request

      settings = Weby::Settings::AssetHost
      return nil if settings.assets_host.blank? && settings.uploads_host.blank?
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

    def self.should_compile? path
      BLACKLIST.each do |black|
        return false if path.to_s.match(black)
      end
      #puts path
      return true
    end

    private

    BLACKLIST = [
        /^codeMirror\//,
        /^datetimepicker\//,
        /^fileupload\//,
        /^floatthead\//,
        /jquery\.cookie\.js/,
        /jquery\.lightbox\_me\.js/,
        /jquery\.nivo\.slider\.pack\.js/,
        /nestedsortable\/jquery\.ui\.nestedSortable\.js/,
        /rgbcolor\.js/,
        /google\/lato\.css/,
        /jquery\.datetimepicker\./,
        /select2\-bootstrap\.css/,
        /^daterangepicker/,
        /^moment(\/|\.js)/,
        #/^fullcalendar/,
        /font\-awesome\.css/,
        /^cropper\.js/,
        /^d3(\.min)?\.js/,
        /^select2/,
        /bootstrap/,
        /^jquery\.ui\./,
        /^jquery(\.ui\.|\.min\.js|\_ujs\.js)/,
        /^_/
      ]

  end
end
