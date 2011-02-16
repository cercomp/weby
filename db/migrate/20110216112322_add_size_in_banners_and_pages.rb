class AddSizeInBannersAndPages < ActiveRecord::Migration
  def self.up
  	add_column :banners, :size, :string
  	add_column :pages, :size, :string
    
    say "Running: rake paperclip:refresh CLASS=Repository"
    ENV['CLASS'] = 'Repository'
    Rake::Task['paperclip:refresh'].invoke
  end

  def self.down
	  remove_column :banners, :size
	  remove_column :pages, :size
  end
end
