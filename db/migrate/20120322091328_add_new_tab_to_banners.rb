class AddNewTabToBanners < ActiveRecord::Migration
  def change
    add_column :banners, :new_tab, :boolean, default: false
    Banner.update_all('new_tab = true', 'repository_id is not null')
  end
end
