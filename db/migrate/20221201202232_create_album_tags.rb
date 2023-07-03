class CreateAlbumTags < ActiveRecord::Migration[5.2]
  def change
    create_table :album_tags do |t|
      t.references :site, foreign_key: true
      t.references :user, foreign_key: true
      t.string :name
      t.string :slug
      t.text :description

      t.timestamps
    end

    create_join_table :album_tags, :albums do |t|
      t.index [:album_id, :album_tag_id]
    end
  end
end
