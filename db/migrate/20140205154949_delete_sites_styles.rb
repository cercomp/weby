class DeleteSitesStyles < ActiveRecord::Migration
  def change
    rename_column :styles, :owner_id, :site_id
    add_column :styles, :style_id, :integer

    add_index :styles, :style_id

    add_foreign_key :styles, :styles

    Style.transaction do
      execute('SELECT * FROM sites_styles').each do |sites_style|
        Style.create!(
          publish: sites_style['publish'],
          site_id: sites_style['site_id'],
          style_id: sites_style['style_id']
        )
      end
    end

    drop_table :sites_styles
  end
end
