class BannerListComponent < Component
  component_settings :category, :orientation, :timer, :description, :show_controls

  validates :category, presence: true

  alias_method :_timer, :timer
  def timer
    _timer.blank? ? '4' : _timer
  end

  def show_controls?
    show_controls.blank? ? false : show_controls == '1'
  end

  def show_description?
    description.blank? ? false :  description == '1'
  end

  def default_alias
    category
  end
end
