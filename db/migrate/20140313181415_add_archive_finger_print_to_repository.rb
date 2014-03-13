class AddArchiveFingerPrintToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :archive_fingerprint, :string
  end
end
