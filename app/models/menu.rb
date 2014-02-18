class Menu < ActiveRecord::Base
  has_many :menu_items, dependent: :destroy, order: :position, include: :i18ns
  has_many :root_menu_items, order: :position, include: :i18ns, class_name: 'MenuItem', conditions: 'parent_id is NULL'

  validates :name, presence: true

  belongs_to :site
  #validates_associated :site
  validates :site_id,
    presence: true,
    numericality: true

  scope :with_items, includes(:menu_items)

  #Returns a hash, with the parent_id and a array as the value
  # ie. {0 => [menuitem1, menuitem2}, 1 => [menuitem3,menuitem4] }
  def items_by_parent published=false
    self.menu_items.send(published ? :published : :scoped).group_by(&:parent_id)
  end

  def self.import attrs, options={}
    return attrs.each{|attr| self.import attr } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['menu'] if attrs.has_key? 'menu'

    attrs.except!('id', 'created_at', 'updated_at', 'site_id', 'type')
    items = attrs.delete('root_menu_items')

    menu = self.create!(attrs)
    if menu.persisted?
      menu.menu_items.import items
    end
  end

end