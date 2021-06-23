class CreateApps < ActiveRecord::Migration[5.2]
  def change
    create_table :apps do |t|
      t.string :name
      t.string :code
      t.boolean :active
      t.string :api_token
      t.string :access_token

      t.timestamps
    end
  end
end
