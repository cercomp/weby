class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.integer  :site_id
      t.string   :archive_file_name
      t.string   :archive_content_type
      t.integer  :archive_file_size
      t.datetime :archive_updated_at
      t.string   :description

      t.timestamps
    end
    
    add_index :repositories, :site_id
    
    add_foreign_key :repositories, :sites
  end
end
