class Menu < ActiveRecord::Base
  has_many :menu_items, dependent: :destroy, order: :position, include: :i18ns, :conditions => proc { ["deleted = false"] }
  #has_many :menu_items, dependent: :delete_all, order: :position, include: :i18ns, -> (where deleted: false) # to updates 4.x
  
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
    if self.deleted
      MenuItem.unscoped.where(menu_id: self.id).group_by(&:parent_id)
    else
      self.menu_items.group_by(&:parent_id)
    end
  end

  default_scope lambda { where(deleted: false) }
  scope :deleted, lambda { where(deleted: true) }

end
