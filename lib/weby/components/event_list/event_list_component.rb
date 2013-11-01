class EventListComponent < Component
  component_settings :quant, :title, :new_tab

  i18n_settings :title

  validates :quant, presence: true

  alias :_title :title
  def title
    _title.blank? ? nil : _title
  end

  alias :_new_tab :new_tab
  def new_tab
    _new_tab.blank? ? false : _new_tab.to_i == 1
  end
end
