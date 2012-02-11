class Locale < ActiveRecord::Base
  has_many :page_i18ns

  has_and_belongs_to_many :sites
end
