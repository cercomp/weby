class CreatePagesNew < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.references :site, index: true
      t.references :user, index: true
      t.boolean :publish, default: false
      t.datetime :deleted_at
      t.integer :view_count

      t.timestamps
    end
    create_table :page_i18ns do |t|
      t.references :page, index: true
      t.references :locale, index: true
      t.string :title
      t.text :text

      t.timestamps
    end
  end
end
