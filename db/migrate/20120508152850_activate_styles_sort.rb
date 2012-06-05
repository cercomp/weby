class ActivateStylesSort < ActiveRecord::Migration
  def up
    sort = Right.where( controller: 'styles', action: 'sort').first
    right = Right.where( controller: 'styles', action: 'edit update').first
    
    Role.all.each do |role|
      if role.rights.include? right
        role.rights << sort
      end
    end
    
  end

  def down
    sort = Right.where( controller: 'styles', action: 'sort').first
    
    Role.all.each do |role|
        role.rights.delete(sort)        
    end
    
  end
  
end
