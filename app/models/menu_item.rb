class MenuItem < ActiveRecord::Base
  weby_content_i18n :title, :description, required: :title

  belongs_to :target, polymorphic: true
  
  belongs_to :menu
  validates :menu_id,
    presence: true

  validates :parent_id, numericality: true, allow_nil: false
  validates :position, numericality: true, allow_nil: false
  
end