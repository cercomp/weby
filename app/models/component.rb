class Component < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  validates :body, :presence => true

  before_save { self.enable ||= true }
  
  belongs_to :site
end
