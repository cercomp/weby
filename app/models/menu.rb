class Menu < ActiveRecord::Base
  belongs_to :site

  has_many :menu_items, -> { order(:position).includes(:i18ns) }, dependent: :destroy
  has_many :root_menu_items, -> { order(:position).includes(:i18ns).where('parent_id is NULL') }, class_name: 'MenuItem'

  validates :name, :site, presence: true

  scope :with_items, -> { includes(:menu_items) }

  # Returns a hash, with the parent_id and a array as the value
  # ie. {0 => [menuitem1, menuitem2}, 1 => [menuitem3,menuitem4] }
  def items_by_parent(published = false)
    if published
      menu_items.published.group_by(&:parent_id)
    else
      menu_items.group_by(&:parent_id)
    end
  end

  def self.import(attrs, _options = {})
    return attrs.each { |attr| import attr } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['menu'] if attrs.key? 'menu'
    id = attrs['id']
    attrs.except!('id', 'created_at', 'updated_at', 'site_id', 'type')
    items = attrs.delete('root_menu_items')

    menu = self.create!(attrs)

    if menu.persisted?
      Import::Application::CONVAR["menu"]["#{id}"] ||= "#{menu.id}"
    end

    menu.menu_items.import items if menu.persisted?
  end
end
