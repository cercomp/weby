class AddShareToBanner < ActiveRecord::Migration
  def up
    create_join_table :sticker_banners, :sites, table_name: 'sticker_banner_sites' do |t|
      t.primary_key :id
      t.index [:sticker_banner_id, :site_id]
      t.integer :position
      t.datetime :date_begin_at
      t.datetime :date_end_at
      t.datetime :created_at
      t.datetime :updated_at
    end

    execute <<-SQL
      INSERT INTO sticker_banner_sites (sticker_banner_id, site_id, position, date_begin_at, date_end_at, created_at, updated_at)
      SELECT id, site_id, position, date_begin_at, date_end_at, created_at, updated_at
      FROM sticker_banners;
      UPDATE taggings SET taggable_type = 'Sticker::BannerSite', taggable_id = (select id from sticker_banner_sites where taggable_id = sticker_banner_sites.sticker_banner_id)
      where taggable_type  = 'Sticker::Banner'
    SQL
  end
end
