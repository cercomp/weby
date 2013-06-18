class CreatePageI18ns < ActiveRecord::Migration
  def change
    create_table :page_i18ns do |t|
      t.integer  :page_id
      t.integer  :locale_id
      t.string   :title
      t.text     :summary
      t.text     :text

      t.timestamps
    end
    
    add_index :page_i18ns, :page_id
    add_index :page_i18ns, :locale_id

    add_foreign_key :page_i18ns, :pages
    add_foreign_key :page_i18ns, :locales
  end
end
