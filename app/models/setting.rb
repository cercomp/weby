class Setting < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name, :value, :description

  validates :value, format: {with: /^https?$/} if :is_login_protocol?

  def is_login_protocol?
    name == "login_protocol"
  end
  
end
