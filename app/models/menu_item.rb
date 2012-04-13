class MenuItem < ActiveRecord::Base
  include WebyI18ns

  has_many :i18ns, class_name: "MenuItem::I18ns", dependent: :delete_all
  accepts_nested_attributes_for :i18ns, allow_destroy: true,
    reject_if: proc { |attr| attr['id'].blank? and attr['title'].blank? }

  belongs_to :target, polymorphic: true
  
  belongs_to :menu
  #validates_associated :menu
  validates :menu_id,
    presence: true,
    numericality: true

  validates :parent_id, numericality: true, allow_nil: false
  validates :position, numericality: true, allow_nil: false

  validates_with WebyI18nContentValidator
  
end