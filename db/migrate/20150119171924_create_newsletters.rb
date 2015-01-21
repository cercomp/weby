class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.integer :site_id
      t.string :group
      t.string :email
      t.string :chave
      t.boolean :confirm

      t.timestamps
    end
  end
end
