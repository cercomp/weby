class AddSkinIdToTables < ActiveRecord::Migration
	class Component < ActiveRecord::Base
		belongs_to: site
	end

	class Style < ActiveRecord::Base
		belongs_to: site
	end

  def change
    add_column :components, :skin_id, :integer
    add_column :styles, :skin_id, :integer
    add_index :components, :skin_id
    add_index :styles, :skin_id

    reversible do |dir|
			dir.up do
				Component.includes(:site).find_each do |component|
					component.create_skin(
						site_id: component.site_id,
						theme: component.site.theme,
						name: component.site.theme.titleize,
						active: true
					)
				end
			end
		end


    remove_column :components, :site_id
    remove_column :styles, :site_id
  end
end
