class AddDeletedAt < ActiveRecord::Migration
  def change
    add_column :pages, :deleted_at, :datetime, default: nil
    add_column :repositories, :deleted_at, :datetime, default: nil
  end
end
