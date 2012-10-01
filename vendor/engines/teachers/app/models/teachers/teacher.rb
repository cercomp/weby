module Teachers
  class Teacher < ActiveRecord::Base
    attr_accessible :email, :name, :website
  end
end
