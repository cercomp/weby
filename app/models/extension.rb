class Extension < ActiveRecord::Base
  self.table_name = 'extension_sites'

  belongs_to :site
  attr_accessible :name, :site_id

  validates :name, :presence => true, :uniqueness => { :scope => :site_id }
  validates :site, :presence => true
end
