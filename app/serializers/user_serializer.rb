class UserSerializer < ActiveModel::Serializer

  attributes :id, :login, :email, :is_admin, :first_name, :last_name,
             :phone, :mobile, :locale, :created_at, :updated_at

end

