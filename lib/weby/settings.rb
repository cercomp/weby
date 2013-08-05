module Weby
  class Settings
    settings_yaml = "config/settings.yml"
    @@default_settings = YAML.load_file(Rails.root.join(settings_yaml))['settings'] if File.exists? settings_yaml
    
    @@default_settings.each do |key, value|
      class_eval <<-METHOD
        def self.#{key}(value_only=true)
          @@settings ||= Setting.all
          sett = @@settings.select{|setting| setting.name == "#{key}" }.first || Setting.new({name: '#{key}', value: @@default_settings['#{key}']['value']})
          sett.default_value = @@default_settings['#{key}']['value']
          value_only ? sett.value : sett
        end
      METHOD
    end

    #As configurações ficam em memória quando sobe o server,
    #chame essa função caso alguma configuração seja alterada
    def self.load_settings
      @@settings = Setting.all
    end

    def self.all
      @@default_settings.map{|key, setting| self.send(key.to_sym, false) }.sort{|a,b| a.name <=> b.name }
    end
  end
end