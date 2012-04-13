class MenuItem::I18ns < ActiveRecord::Base
  belongs_to :menu_item
  
  belongs_to :locale
  #validates_associated :locale
  validates :locale_id,
    presence: true,
    numericality: true

  validates :title,
    presence: true
end