class AddUserToRepositories < ActiveRecord::Migration[5.2]
  def change
    add_reference :repositories, :user, foreign_key: true
  end
end
