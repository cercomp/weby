class Pagina < ActiveRecord::Base
  belongs_to :user, :foreign_key => "autor_id"
end
