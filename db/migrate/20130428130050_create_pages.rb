class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.datetime :date_begin_at
      t.datetime :date_end_at
      t.string   :status
      t.integer  :author_id
      t.string   :url
      t.integer  :site_id
      t.string   :source
      t.string   :kind
      t.string   :local
      t.datetime :event_begin
      t.datetime :event_end
      t.string   :event_email
      t.string   :subject
      t.string   :align
      t.string   :type
      t.integer  :repository_id
      t.string   :size
      t.boolean  :publish,
        default: false
      t.boolean  :front,
        default: false
      t.integer  :position
      t.integer  :view_count,
        default: 0

      t.timestamps
    end
    
    add_index :pages, :author_id
    add_index :pages, :site_id
    add_index :pages, :repository_id
    
    add_foreign_key :pages, :users, column: :author_id
    add_foreign_key :pages, :sites
    add_foreign_key :pages, :repositories
  end
end
