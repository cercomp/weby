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
    institutions_hash.map { |name, values| [values[:name], name] }
  end

  def institution_value(path)
    @institution ||= institutions_hash[institution] || {}
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

  private

  def institutions_hash
    {
      ufg: {
        name: 'Universidade Federal de Goiás',
        url: 'http://www.ufg.br',
        logo: {
          small: 'institutions/logo-s.png'
        },
        links: {
          label: {
            'pt-BR' => 'Sistemas UFG',
            'en' => 'UFG Systems'
          },
          list: {
            'Portal UFGNet' => 'http://ufgnet.ufg.br',
            'Webmail' => 'http://mail.ufg.br',
            'Matrícula' => 'https://sigaa.sistemas.ufg.br',
            'Concursos' => 'http://sistemas.ufg.br/CONCURSOS_WEB/',
            'Portal SIG' => 'http://portalsig.ufg.br'
          },
          bar: {
            'Portal UFG' => 'http://www.ufg.br',
            'Portal UFGNet' => 'http://ufgnet.ufg.br',
            'Pró-reitorias' => 'http://www.ufg.br/p/6397',
            'Unidades Acadêmicas' => 'http://www.ufg.br/p/6408',
            'Concursos' => 'http://www.prodirh.ufg.br',
            'Vestibular' => 'http://www.vestibular.ufg.br',
            'Fale Conosco' => 'http://www.ufg.br/feedback',
            'Dúvidas frequentes' => 'http://www.ufg.br/p/6111'
          }
        },
      }
    }.with_indifferent_access
  end
end
