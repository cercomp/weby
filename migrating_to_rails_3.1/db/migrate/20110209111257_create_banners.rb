class CreateBanners < ActiveRecord::Migration
  def self.up
    create_table :banners do |t|
      t.datetime :date_begin_at
      t.datetime :date_end_at
      t.string :title
      t.text :text
      t.string :url
      t.integer :width
      t.integer :height
      t.boolean :hide
      t.integer :repository_id
      t.integer :user_id

      t.timestamps
    end
    create_table :sites_banners do |t|
      t.integer :site_id
      t.integer :banner_id

      t.timestamps
    end
  end

  def self.down
    drop_table :banners
    drop_table :sites_banners
  end
end
