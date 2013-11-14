class MenuItem < ActiveRecord::Base
  weby_content_i18n :title, :description, required: :title

  belongs_to :target, polymorphic: true
  
  belongs_to :menu
  validates :menu_id,
    presence: true

	belongs_to :parent, class_name: 'MenuItem'
	has_many :children, class_name: 'MenuItem', foreign_key: 'parent_id', dependent: :destroy

  validates_format_of :html_class, :with => /^[A-Za-z0-9_\-]*$/
  validates :position, numericality: true, allow_nil: false
end
