class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.datetime :date_begin_at
      t.datetime :date_end_at
      t.string   :title
      t.text     :text
      t.string   :url
      t.integer  :width
      t.integer  :height
      t.boolean  :hide,
        default: false
      t.integer  :repository_id
      t.integer  :user_id
      t.string   :size
      t.boolean  :publish,
        default: false
      t.integer  :site_id
      t.integer  :position
      t.integer  :page_id
      t.boolean  :new_tab,
        default: false
      t.integer  :click_count,
        default: 0

      t.timestamps
    end
    
    add_index :banners, :repository_id
    add_index :banners, :user_id
    add_index :banners, :site_id
    add_index :banners, :page_id
    
    add_foreign_key :banners, :repositories
    add_foreign_key :banners, :users
    add_foreign_key :banners, :sites
    add_foreign_key :banners, :pages
  end
end
