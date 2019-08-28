class ImageComponent < Component
  component_settings :repository_id, :size, :height, :width, :target_type, :target_id, :url,
  					 :new_tab, :html_class, :default_image, :title

  i18n_settings :repository_id, :title

  alias_method :_new_tab, :new_tab
  def new_tab
    _new_tab.blank? ? false : _new_tab.to_i == 1
  end

  validates :html_class, format: { with: /\A[A-Za-z0-9_\-\s]*\z/ }
  validates :repository_id, presence: true, unless: :default_image

  belongs_to :target, polymorphic: true
end
