class Menu < ActiveRecord::Base

  belongs_to :menu, :foreign_key => "father_id"

end
