class AddPositionToFeedbackGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :feedback_groups, :position, :integer
  end
end
