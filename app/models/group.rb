class Group < ActiveRecord::Base

  belongs_to :site

  has_and_belongs_to_many :users
  has_and_belongs_to_many :feedbacks

  validates_presence_of :name

  # Usuarios que estão fora deste grupo
  def users_off_groups
    User.find(:all) - self.users
  end

end
