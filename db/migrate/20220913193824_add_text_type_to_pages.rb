class AddTextTypeToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :text_type, :string
    add_column :journal_news, :text_type, :string
    add_column :calendar_events, :text_type, :string
  end
end
