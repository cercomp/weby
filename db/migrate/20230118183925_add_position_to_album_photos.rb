class AddPositionToAlbumPhotos < ActiveRecord::Migration[5.2]
  def change
    add_column :album_photos, :position, :integer
    add_column :album_photos, :slug, :string
  end
end
