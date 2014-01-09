class ImageComponent < Component
  component_settings :repository_id, :size, :height, :width, :target_type, :target_id, :url, :new_tab, :html_class

  i18n_settings :repository_id

  alias :_new_tab :new_tab
  def new_tab
    _new_tab.blank? ? false : _new_tab.to_i == 1
  end

  validates_format_of :html_class, :with => /^[A-Za-z0-9_\-]*$/
  validates :repository_id, presence: true
  
  belongs_to :target, polymorphic: true
end
