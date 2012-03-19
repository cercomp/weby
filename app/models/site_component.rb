class SiteComponent < ActiveRecord::Base
  before_create { self.publish ||= true }
  belongs_to :site

  validates :place_holder, presence: true
  validates :component, presence: true

  def self.by_setting(setting, value)
    self.where("settings LIKE '%:#{setting} => \"#{value}\"%'")
  end
end