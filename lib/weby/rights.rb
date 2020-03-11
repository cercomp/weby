module Weby
  class Rights
    class << self
      begin
        @@rights = YAML.load(ERB.new(File.read(Rails.root.join('lib', 'weby', 'config', 'rights.yml'))).result)['rights']
        Dir.glob File.expand_path('vendor/engines/*', Rails.root) do |extension_dir|
          file = File.join(extension_dir, 'lib/weby/config/rights.yml')
          if File.exist?(file)
            @@rights = YAML.load(ERB.new(File.read(file)).result)['rights'].merge @@rights
          end
        end
      end

      def permissions site=nil
        site && site.restrict_theme ? @@rights.except('skins') : @@rights
      end

      def actions(controller, permission)
        @@rights.fetch(controller, {}).fetch(permission, 'action' => '')['action'].split(' ')
      end

      def permission(controller, action)
        action = action.split(' ').first
        ctrl = @@rights.fetch(controller, {})
        return action if ctrl[action]
        ctrl.each do |permission, config|
          return permission if config['action'].include? action
        end
        nil
      end

      def seed_roles(site_id = nil)
        roles  = YAML.load(ERB.new(File.read(Rails.root.join('lib', 'weby', 'config', 'roles.yml'))).result)

        roles.each do |name, values|
          permissions = {}.to_s
          case values['permissions']
          when Hash
            permissions = values['permissions'].to_s
          when String
            if values['permissions'] == 'all'
              permissions = Hash[Weby::Rights.permissions.map { |controller, actions| [controller, actions.keys] }].to_s
            end
          end
          Role.create(name: name, permissions: permissions, site_id: site_id)
        end
      end
    end
  end
end
