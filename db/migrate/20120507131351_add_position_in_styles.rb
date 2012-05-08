class AddPositionInStyles < ActiveRecord::Migration
  def up
    add_column :styles, :position, :integer
    
    Site.all.each do |site|
      position = site.own_styles.count
      
      site.own_styles.each do |style|
        style.update_attribute(:position, position)
        position = position - 1
      end
    end
  end

  def down
    remove_column :styles, :position
  end
end
