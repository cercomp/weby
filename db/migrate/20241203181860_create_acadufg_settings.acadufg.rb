# This migration comes from acadufg (originally 20130307201302)
class CreateAcadufgSettings < ActiveRecord::Migration[4.2]
  def change
    return if table_exists?(:acadufg_settings)

    create_table :acadufg_settings do |t|
      t.integer :site_id
      t.integer :programa_id

      t.timestamps
    end

    add_index :acadufg_settings, :site_id unless index_exists?(:acadufg_settings, :site_id)

    add_foreign_key :acadufg_settings, :sites unless foreign_key_exists?(:acadufg_settings, :sites)
  end
end
