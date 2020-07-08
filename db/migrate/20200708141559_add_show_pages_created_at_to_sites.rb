class AddShowPagesCreatedAtToSites < ActiveRecord::Migration[5.2]
  def change
    rename_column :sites, :view_desc_pages, :show_pages_author
    add_column :sites, :show_pages_created_at, :boolean, default: false
    add_column :sites, :show_pages_updated_at, :boolean, default: false

    reversible do |dir|
      dir.up do
        # author -> show_author
        Extension.where(name: 'journal').find_each do |extension|
          extension.settings['show_author'] = extension.settings.delete('author')
          extension.save!
        end
      end

      dir.down do
        #
      end
    end
  end
end
