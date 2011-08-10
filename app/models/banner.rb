class Banner < ActiveRecord::Base
  default_scope :conditions => { :hide => false }, :order => 'position,id DESC'
  
  scope :unhide, :conditions => { :hide => false }, :order => 'position,id DESC'
  scope :category, lambda { |cat| where("publish = true AND category = ?", cat)}

  scope :titles_or_texts_like, lambda { |str|
      where(["LOWER(str) like ? OR LOWER(str) like ?", "%#{str.downcase if str}%"])
  }

	belongs_to :repository, :foreign_key => "repository_id"
  belongs_to :user, :foreign_key => "user_id"
	belongs_to :site, :foreign_key => "site_id"

  validates_presence_of :url, :title, :text, :user_id
end
