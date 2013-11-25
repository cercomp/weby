class CreateGroupings < ActiveRecord::Migration
  def change
    create_table :groupings do |t|
      t.string :name
      
      t.timestamps
    end

    create_table :groupings_sites do |t|
      t.belongs_to :grouping
      t.belongs_to :site
    end
  end
end
