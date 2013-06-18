class CreateAcadufgSettings < ActiveRecord::Migration
  def change
    create_table :acadufg_settings do |t|
      t.integer :site_id
      t.integer :programa_id

      t.timestamps
    end

    add_index :acadufg_settings, :site_id

    add_foreign_key :acadufg_settings, :sites
  end
end
