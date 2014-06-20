class InstitutionalLinksComponent < Component
  component_settings :institution, :html_class, :format, :new_tab

  validates :institution, presence: true

  alias_method :_format, :format
  def format
    _format.blank? ? format_list[0] : _format
  end

  alias_method :_new_tab, :new_tab
  def new_tab
    _new_tab.blank? ? false : _new_tab.to_i == 1
  end

  def format_list
    %w(bar list)
  end

  def institutions_as_options
    Weby.institutions.map { |name, values| [values['name'], name] }
  end

  def institution_value(path)
    @institution ||= Weby.institutions[institution] || {}
    result = nil
    path.split('.').each do |level|
      result ||= @institution
      result = result.fetch(level, {})
    end
    result.empty? ? nil : result
  end

  def institution_links(format)
    institution_value("links.#{format}") || []
  end

  def default_alias
    I18n.t("institutional_links.views.form.#{format}")
  end

  def label
    labels = institution_value('links.label') || {}
    labels[I18n.locale.to_s] # || labels.values[0]
  end
end
