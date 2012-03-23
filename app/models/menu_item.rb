class MenuItem < ActiveRecord::Base
  has_many :i18ns, class_name: "MenuItem::I18n", dependent: :delete_all
  #validates_associated :i18ns
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
  
  # Find i18n based on locale_name
  # Example: locale_name = 'pt-BR'
  def i18n(locale_name)
    loc = Locale.find_by_name(locale_name)
    if loc
      i18nitem = self.i18ns.where({locale_id: loc.id}).first
      unless i18nitem
        i18nitem = self.i18ns.first
      end
    end
    i18nitem
  end
  
end