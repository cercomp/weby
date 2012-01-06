class Group < ActiveRecord::Base

  belongs_to :site
  has_and_belongs_to_many :feedbacks

  # TODO verificar a necessidade do relacionamento com usuários
  has_and_belongs_to_many :users

  validates_presence_of :name, :emails

  # TODO verificar a utilização deste método, parece obsoleto no sistema
  # Usuarios que estão fora deste grupo
  def users_off_groups
    User.find(:all) - self.users
  end
end
