class AddSettingsToSite < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :settings, :jsonb, default: {}
    add_column :extensions, :settings, :jsonb, default: {}

    reversible do |dir|
      dir.up do
        # updated_at -> show_updated_at
        # created_at -> show_created_at
        Extension.find_each do |extension|
          r_settings = ActiveRecord::Base.connection.exec_query("SELECT * from weby_settings WHERE thing_id = #{extension.id} AND thing_type = 'Extension'")
          r_settings.to_hash.each do |setting|
            name = case setting['var']
            when 'updated_at'
              'show_updated_at'
            when 'created_at'
              'show_created_at'
            else
              setting['var']
            end
            extension.settings[name] = YAML.load(setting['value']) if setting['value'].present?
          end
          extension.save!
        end
        #
        Site.find_each do |site|
          r_settings = ActiveRecord::Base.connection.exec_query("SELECT * from weby_settings WHERE thing_id = #{site.id} AND thing_type = 'Site'")
          r_settings.to_hash.each do |setting|
            site.settings[setting['var']] = YAML.load(setting['value']) if setting['value'].present?
          end
          site.save!
        end
        #ActiveRecord::Base.connection.execute("DROP TABLE weby_settings")
      end
      dir.down do
        #
      end
    end
  end
end
