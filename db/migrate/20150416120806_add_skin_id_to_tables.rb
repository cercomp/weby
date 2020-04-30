class AddSkinIdToTables < ActiveRecord::Migration
	class Site < ApplicationRecord
		has_many :components
		has_many :styles
	end

	class Component < ApplicationRecord
		belongs_to :site
	end

	class Style < ApplicationRecord
		belongs_to :site
	end

  def change
    add_column :components, :skin_id, :integer
    add_column :styles, :skin_id, :integer
    add_index :components, :skin_id
    add_index :styles, :skin_id

    reversible do |dir|
  		dir.up do
  			Site.find_each do |site|
  				skin = Skin.new(site_id: site.id,
  					theme: site.theme,
  					name: site.theme.titleize,
  					active: true
  				)
  				skin.save!
  				site.components.update_all(skin_id: skin.id)
  				site.styles.update_all(skin_id: skin.id)
  			end
  		end
  	end


    remove_column :components, :site_id
    remove_column :styles, :site_id
  end
end
