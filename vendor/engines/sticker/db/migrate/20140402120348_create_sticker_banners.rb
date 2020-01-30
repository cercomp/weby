class CreateStickerBanners < ActiveRecord::Migration
  def change
    create_table :sticker_banners do |t|
      t.datetime :date_begin_at
      t.datetime :date_end_at
      t.string :title
      t.text :text
      t.string :url
      t.integer :width
      t.integer :height
      t.boolean :hide, default: false
      t.integer :repository_id
      t.integer :user_id
      t.string :size
      t.boolean :publish, default: false
      t.integer :site_id
      t.integer :position
      t.integer :page_id
      t.boolean :new_tab, default: false
      t.integer :click_count, default: 0
      t.timestamps
    end

    add_index :sticker_banners, :repository_id
    add_index :sticker_banners, :user_id
    add_index :sticker_banners, :site_id
    add_index :sticker_banners, :page_id

    add_foreign_key :sticker_banners, :repositories
    add_foreign_key :sticker_banners, :users
    add_foreign_key :sticker_banners, :sites
    add_foreign_key :sticker_banners, :pages
  end
end
