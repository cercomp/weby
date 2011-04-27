class Setting < ActiveRecord::Base
  validates_uniqueness_of :name

  def self.get(name)
    if self.where(:name => name.to_s).blank?
      nil
    else
      self.where(:name => name.to_s).first.value
    end
  end
end
