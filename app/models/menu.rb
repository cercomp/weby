class Menu < ActiveRecord::Base
  has_many :menu_items, dependent: :destroy, order: :position, include: :i18ns
  
  validates :name, presence: true

  belongs_to :site
  #validates_associated :site
  validates :site_id,
    presence: true,
    numericality: true

  scope :with_items, includes(:menu_items)

  #Returns a hash, with the parent_id and a array as the value
  # ie. {0 => [menuitem1, menuitem2}, 1 => [menuitem3,menuitem4] }
  def items_by_parent
    self.menu_items.group_by(&:parent_id)
  end
end