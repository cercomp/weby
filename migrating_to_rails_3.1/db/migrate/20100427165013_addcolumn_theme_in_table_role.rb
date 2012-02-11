class AddcolumnThemeInTableRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :theme, :string, :null => true

    say "Adicionando index na join table rights_roles"
      add_index(:rights_roles, [:role_id, :right_id])
  end

  def self.down
    remove_column :roles, :theme
  end
end
