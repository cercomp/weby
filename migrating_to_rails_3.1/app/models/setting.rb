class Setting < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name, :value, :description

  def self.get(name)
    self.where(:name => name.to_s).first.try(:value)
  end
end
