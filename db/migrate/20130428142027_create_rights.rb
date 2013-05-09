class CreateRights < ActiveRecord::Migration
  def change
    create_table :rights do |t|
      t.string   :name
      t.string   :controller
      t.string   :action

      t.timestamps
    end
  end
end
