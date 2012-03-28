class MenuItem < ActiveRecord::Base
  has_many :i18ns, class_name: "MenuItem::I18n", dependent: :delete_all
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
  
  # Find i18n based on locale
  def i18n(locale)
    selected_locale = self.i18ns.select{|i18n| i18n.locale_id == locale.id }
    return selected_locale.first if selected_locale.any?

    self.i18ns.first
  end
  
end