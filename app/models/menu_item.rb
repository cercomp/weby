class MenuItem < ApplicationRecord
  weby_content_i18n :title, :description, required: :title

  belongs_to :target, polymorphic: true, optional: true
  belongs_to :menu
  belongs_to :parent, class_name: 'MenuItem', optional: true

  has_many :children, class_name: 'MenuItem', foreign_key: 'parent_id', dependent: :destroy

  validates :menu_id, presence: true
  validates :position, numericality: true, allow_nil: false
  validates :html_class, format: { with: /\A[A-Za-z0-9_\-]*\z/ }

  scope :published, -> { where(publish: true) }

  after_save :save_childrens

  def update_positions(positions)
    positions = positions_by_parent(positions)
    positions.fetch(parent_id, []).each_with_index do |item_id, idx|
      MenuItem.find(item_id).update_attribute(:position, idx + 1)
    end
    if parent_id != @new_parent
      positions.fetch(@new_parent, []).each_with_index do |item_id, idx|
        attrs = { position: idx + 1 }
        attrs[:parent_id] = @new_parent if item_id == id
        MenuItem.find(item_id).update(attrs)
      end
    end
  end

  def self.import(attrs, options = {})
    return attrs.each { |attr| import attr } if attrs.is_a? Array

    attrs = attrs.dup
    attrs.except!('id', 'created_at', 'updated_at', 'menu_id', 'parent_id', 'target_id', 'target_type', '@type', 'type')
    attrs.except!('url') if attrs['url'] && !attrs['url'].match(/^https?:\/\//)
    children = attrs.delete('children')

    attrs['i18ns'] = attrs['i18ns'].map { |i18n| self::I18ns.new(i18n.except('id', 'type', 'created_at', 'updated_at', 'menu_item_id')) }

    menu_item = self.create!(attrs.merge(parent_id: options[:parent_id]))
    if menu_item.persisted?
      children.each do |child|
        import child, parent_id: menu_item.id
      end
    end
  end

  def serializable_hash(options = {})
    options.merge!(include: [:i18ns, :children])
    super options
  end

  def target_namespace
    target_type == 'Page' ? :site_admin : :admin
  end

  def self.new_or_clone id, params={}
    if id.present?
      menu_item = current_scope.find_by(id: id)
      if menu_item
        return current_scope.new(
          url: menu_item.url,
          target: menu_item.target,
          new_tab: menu_item.new_tab,
          publish: menu_item.publish,
          html_class: menu_item.html_class,
          i18ns_attributes: menu_item.i18ns.map do |i18n|
            {
              locale: i18n.locale,
              title: i18n.title,
              description: i18n.description
            }
          end
        )
      end
    end
    #default
    current_scope.new(params)
  end

  private

  def positions_by_parent(serialized)
    hierarchy = {}
    serialized.each do |item, parent|
      parent = %w(root null).include?(parent) ? nil : parent.to_i
      hierarchy[parent] ||= []
      hierarchy[parent] << item.to_i
      @new_parent = parent if item.to_i == id
    end
    hierarchy
  end

  def save_childrens
    if publish_changed?
      children.each do |child|
        child.update_attribute(:publish, publish)
      end
    end
    if menu_id_changed?
      children.each do |child|
        child.update_attribute(:menu_id, menu_id)
      end
    end
  end
end
