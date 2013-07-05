class MenuItem < ActiveRecord::Base
  weby_content_i18n :title, :description, required: :title

  belongs_to :target, polymorphic: true
  
  belongs_to :menu
  validates :menu_id,
    presence: true

  validates_format_of :html_class, :with => /^[A-Za-z0-9_\-]*$/
  validates :position, numericality: true, allow_nil: false
end
