class Locale < ActiveRecord::Base
  has_many :news,
    class_name: "Page::I18ns"

  has_and_belongs_to_many :sites
end
