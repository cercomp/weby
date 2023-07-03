class CreateAlbums < ActiveRecord::Migration[5.2]
  def change
    create_table :albums do |t|
      t.references :site, index: true
      t.references :user, index: true
      t.boolean :publish
      t.integer :view_count
      t.integer :photos_count
      t.string :slug
      t.string :source
      t.string :video_url

      t.timestamps
    end
    create_table :album_i18ns do |t|
      t.references :album, index: true
      t.references :locale, index: true
      t.string :title
      t.text :text

      t.timestamps
    end
    create_table :album_photos do |t|
      t.references :album, index: true
      t.references :user, index: true
      t.boolean :is_cover, default: false
      t.string :image_file_name
      t.string :image_content_type
      t.string :image_updated_at
      t.string :image_fingerprint
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
