class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string   :name
      t.string   :url
      t.text     :description
      t.integer  :body_width
      t.text     :footer
      t.string   :theme
      t.boolean  :view_desc_pages,
        default: false
      t.string   :per_page,
        default: "5, 15, 30, 50, 100"
      t.integer  :per_page_default,
        default: 25
      t.boolean  :menu_dropdown,
        default: false
      t.string   :title,
        limit: 50
      t.integer  :parent_id
      t.integer  :view_count,
        default: 0

      t.timestamps
    end

    add_index :sites, :parent_id 

    add_foreign_key :sites, :sites, column: :parent_id
  end
end
