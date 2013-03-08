class CreateAcadufgSettings < ActiveRecord::Migration
  def change
    create_table :acadufg_settings do |t|
      t.integer :site_id
      t.integer :programa_id

      t.timestamps
    end
  end
end
