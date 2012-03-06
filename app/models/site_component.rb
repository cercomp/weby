class SiteComponent < ActiveRecord::Base
  before_create { self.publish ||= true }
  belongs_to :site

  def self.by_setting(setting, value)
    self.where("settings LIKE '%:#{setting} => \"#{value}\"%'")
  end
end