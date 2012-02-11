class AlterValueUsersTheme < ActiveRecord::Migration
  def self.up
    user = User.where(:theme => "this2html5")
    unless user.empty?
      user.update_all(:theme => "this2")
    end
  end

  def self.down
    user = User.where(:theme => "this2")
    unless user.empty?
      user.update_all(:theme => "this2html5")
    end
  end
end
