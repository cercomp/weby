class CreateStyles < ActiveRecord::Migration
  def change
    create_table :styles do |t|
      t.string   :name
      t.text     :css
      t.boolean  :publish,
        default: true
      t.integer  :owner_id
      t.integer  :position,
        default: 0

      t.timestamps
    end
    
    add_index :styles, :owner_id

    add_foreign_key :styles, :sites, column: :owner_id
  end
end
