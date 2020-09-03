class UserEnroleSerializer < ActiveModel::Serializer
  attributes :id, :fullname, :login,

  def login
    object.login if scope.current_user.is_admin?
  end
end
