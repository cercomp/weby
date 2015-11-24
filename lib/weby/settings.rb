module Weby

  class Settings
    settings_yaml = 'lib/weby/config/settings.yml'
    @@groups = Array.new
    @@default_settings = Hash.new
    @@group_settings = YAML.load_file(Rails.root.join(settings_yaml))['settings'] if File.exist? settings_yaml
    @@group_settings.each do |name, attributes|
      @@groups << name
      class_eval <<-METHOD
        class #{name.classify}
          @attributes = #{attributes}
        end

        def #{name.classify}.all
          @attributes.map { |key, _setting| send(key.to_sym, false) }.sort { |a, b| a.name <=> b.name }
        end

        def #{name.classify}.clear
          @settings = nil
        end
        METHOD

      @@default_settings.merge!(attributes)
      @@default_settings.each do |key, _value|
        class_eval <<-METHOD
          def #{name.classify}.#{key}(value_only=true)
            @settings ||= Setting.all
            sett = @settings.select{|setting| setting.name == "#{key}" }.first || Setting.new({name: '#{key}', value: @@default_settings['#{key}']['value'], group: '#{name}'})
            sett.default_value = @@default_settings['#{key}']['value']
            value_only ? sett.value : sett
          end
        METHOD
      end
    end

    # The configurations are stored in memory ( @settings )
    # at the end of an requisition call the clear function in order to reload it at the next call
    # of any configuration
    def self.clear
      @@groups.each do |value|
        "Weby::Settings::#{value.classify}".constantize.clear
      end
    end

    def self.groups
      @@groups
    end

    def self.all
      @@groups.map do |value|
        "Weby::Settings::#{value.classify}".constantize.all
      end.flatten
    end
  end

end
