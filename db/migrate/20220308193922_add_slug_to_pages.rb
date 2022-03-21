class AddSlugToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :slug, :string
    add_column :journal_news, :slug, :string
    add_column :calendar_events, :slug, :string
  end
end
