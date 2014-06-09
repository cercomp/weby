module Weby
  class Settings
    settings_yaml = 'lib/weby/config/settings.yml'
    @@default_settings = YAML.load_file(Rails.root.join(settings_yaml))['settings'] if File.exist? settings_yaml

    @@default_settings.each do |key, _value|
      class_eval <<-METHOD
        def self.#{key}(value_only=true)
          @settings ||= Setting.all
          sett = @settings.select{|setting| setting.name == "#{key}" }.first || Setting.new({name: '#{key}', value: @@default_settings['#{key}']['value']})
          sett.default_value = @@default_settings['#{key}']['value']
          value_only ? sett.value : sett
        end
      METHOD
    end

    # The configurations are stored in memory ( @settings )
    # at the end of an requisition call the clear function in order to  reload it at  the next call
    # of any confiuration
    def self.clear
      @settings = nil
    end

    def self.all
      @@default_settings.map { |key, _setting| send(key.to_sym, false) }.sort { |a, b| a.name <=> b.name }
    end
  end
end
