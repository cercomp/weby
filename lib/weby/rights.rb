module Weby
  class Rights
    class << self

      begin
        @@rights = YAML.load(ERB.new(File.read(Rails.root.join("config","rights.yml"))).result)["rights"]
        Dir.glob File.expand_path("vendor/engines/*", Rails.root) do |extension_dir|
          file = File.join(extension_dir, "config/rights.yml")
          if File.exists?(file)
            @@rights = YAML.load(ERB.new(File.read(file)).result)["rights"].merge @@rights
          end
        end
      end

      def permissions
        @@rights
      end

      def actions(controller, permission)
        @@rights.fetch(controller, {}).fetch(permission, {'action' => ''})['action'].split(' ')
      end

      def permission(controller, action)
        action = action.split(' ').first
        ctrl = @@rights.fetch(controller, {})
        return action if ctrl[action]
        ctrl.each do |permission, config|
          return permission if config['action'].include? action
        end
        return nil
      end
    end
  end
end
