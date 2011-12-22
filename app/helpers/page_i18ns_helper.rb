module PageI18nsHelper

  # Retorna o link para adicionar o i18n para uma página
  # Parametros: pagina, site
  def link_to_add_page_i18n(page, site)
    if check_permission(PagesController, ['edit'] )
      if page.page_i18ns.size < Locale.all.size #verifica se todos os locales já foram utilizados
        link_to (t('i18n')), add_i18n_site_page_path(site, page), :class => 'icon icon-i18n'
      else 
        image_tag("menus/i18n_off.png", :alt => t("no_more_i18ns")) + t('i18n')
      end
    end
  end

end
