class Menu < ActiveRecord::Base
  has_many :menu_items, dependent: :delete_all
  
  validates :name, presence: true

  belongs_to :site
  #validates_associated :site
  validates :site_id,
    presence: true,
    numericality: true
end