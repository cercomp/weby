class EventListComponent < Component
  component_settings :quant, :title

  i18n_settings :title

  validates :quant, presence: true

  alias :_title :title
  def title
    _title.blank? ? nil : _title
  end
end
