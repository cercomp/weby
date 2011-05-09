class Banner < ActiveRecord::Base
  default_scope :conditions => { :hide => false }, :order => 'position,id DESC'
  
  scope :unhide, :conditions => { :hide => false }, :order => 'position,id DESC'
  scope :category, lambda { |cat| where("category = ?", cat)}

	belongs_to :repository, :foreign_key => "repository_id"
  belongs_to :user, :foreign_key => "user_id"
	belongs_to :site, :foreign_key => "site_id"

  validates_presence_of :url, :title, :text, :user_id
end
