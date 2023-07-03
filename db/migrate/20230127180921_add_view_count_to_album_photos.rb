class AddViewCountToAlbumPhotos < ActiveRecord::Migration[5.2]
  def change
    add_column :album_photos, :view_count, :integer
    add_column :album_photos, :image_file_size, :integer
  end
end
