class InstitutionalLinksComponent < Component

  component_settings :institution, :html_class, :format, :new_tab

  validates :institution, presence: true

  alias :_format :format
  def format
    _format.blank? ? format_list[0] : _format
  end

  alias :_new_tab :new_tab
  def new_tab
    _new_tab.blank? ? false : _new_tab.to_i == 1
  end

  def format_list
    ['bar', 'list']
  end

  def institutions_as_options
    Weby.institutions.map{|name, values| [values['name'], name]}
  end

  def institution_values
    @institution ||= Weby.institutions[self.institution]
  end

  def default_alias
    I18n.t("institutional_links.views.form.#{self.format}")
  end

  def label
    labels = self.institution_values['links']['label'] || {}
    labels[I18n.locale] #|| labels.values[0]
  end
end
