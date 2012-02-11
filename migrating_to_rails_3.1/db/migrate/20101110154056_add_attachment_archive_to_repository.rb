class AddAttachmentArchiveToRepository < ActiveRecord::Migration
  def self.up
    add_column :repositories, :archive_file_name, :string
    add_column :repositories, :archive_content_type, :string
    add_column :repositories, :archive_file_size, :integer
    add_column :repositories, :archive_updated_at, :datetime
  end

  def self.down
    remove_column :repositories, :archive_file_name
    remove_column :repositories, :archive_content_type
    remove_column :repositories, :archive_file_size
    remove_column :repositories, :archive_updated_at
  end
end
