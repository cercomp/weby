class AddThemeToComponents < ActiveRecord::Migration
  def change
    add_column :components, :theme, :string
  end
end
