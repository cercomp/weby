class Setting < ActiveRecord::Base
  validates_uniqueness_of :name
  
  def self.get(name)
   self.find_by_name(name.to_s).value
  end
end
