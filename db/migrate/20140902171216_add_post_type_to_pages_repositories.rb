class AddPostTypeToPagesRepositories < ActiveRecord::Migration
  def up
    add_column :pages_repositories, :post_type, :string
    rename_column :pages_repositories, :page_id, :post_id
    rename_table :pages_repositories, :posts_repositories

    PostsRepository.all.each do |post_repository|
      post_repository.update_attribute :post_type, Page.name
    end
  end

  def down
    rename_table :posts_repositories, :pages_repositories
    remove_column :pages_repositories, :post_type
    rename_column :pages_repositories, :post_id, :page_id
  end
end
