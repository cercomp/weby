class Banner < ActiveRecord::Base
  default_scope :conditions => { :hide => false }, :order => 'created_at DESC'
  named_scope :unhide, :conditions => { :hide => false }, :order => 'created_at DESC'

	belongs_to :repository, :foreign_key => "repository_id"
  belongs_to :user, :foreign_key => "user_id"

  has_many :sites_banners
  has_many :sites, :through => :sites_banners
  
  validates_presence_of :url, :title, :text, :user_id
  accepts_nested_attributes_for :sites_banners, :allow_destroy => true
end
