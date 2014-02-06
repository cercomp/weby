class AddDeletedAt < ActiveRecord::Migration
  def change
    add_column :pages, :deleted_at, :datetime
    add_column :repositories, :deleted_at, :datetime
  end
end
