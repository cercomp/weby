class AddPublishToStyles < ActiveRecord::Migration
  def change
    add_column :styles, :publish, :boolean
  end
end
