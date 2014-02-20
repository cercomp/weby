#coding: utf-8
module ApplicationHelper
  def session_user
    @session_user ||= User.find(:first, :conditions => ['id = ?', session[:user]])
  end

  def is_in_admin_context?
    request.path.split('/').first(3).include?('admin')
  end

  def is_in_profile_context?
    paths = request.path.split('/').first(2)
    paths.include?('profiles') || paths.include?('notifications')
  end

  def is_in_sites_index?
    (request.path == "/" or request.path.match(/^\/sites\/page\/\d+/)) and !current_site
  end

  def not_in_site_context?
    !current_site || is_in_admin_context? || is_in_profile_context? || is_in_sites_index?
  end

  # Define os menus
  # Parâmetros: Lista de menu (sons, view_ctrl=false)
  # html_class: "dropdown" ou "expanded"
  # Retorna: O menu com seus controles
  def print_menu(menu, view_ctrl: false, html_class: "expanded")
    return '' unless menu
    menuitems = menu.items_by_parent(!view_ctrl)
    content_tag :menu, class: html_class do
      menuitems.fetch(nil, []).map do |child|
        print_menu_entry(menuitems, child, view_ctrl)
      end.join.html_safe
    end
  end

  # Método recursivo para gerar submenus e os controles
  def print_menu_entry(sons, entry, view_ctrl)
    has_submenu = sons[entry.id].present?
    is_current_page = (@page && @page == entry.target) || request.path == entry.url
    item_class = entry.html_class.present? ? [entry.html_class] : []
    item_class << 'sub' if has_submenu
    item_class << 'current_page' if is_current_page
    
    content_tag :li, id: "menu_item_#{entry.id}", class: item_class.join(" ") do
      title_link = link_to(entry.title,
        entry.target_id.to_i > 0 ? main_app.site_page_path(entry.target_id) : entry.url,
        alt: entry.title, title: entry.description, target: entry.new_tab ? "_blank":"")

      li_content = []
      li_content << content_tag(:div, '', class: 'hierarchy') if view_ctrl
      li_content << if view_ctrl
        content_tag(:div, style: 'min-height: 25px', class: "menuitem-ctrl#{' deactivated' unless entry.publish}") do
          div_content = []
          div_content << content_tag(:span) do
            [
              toggle_field(entry, "publish", 'toggle', {controller: 'sites/admin/menus/menu_items', menu_id: entry.menu_id}),
              #" #{entry.position}",
              " #{title_link}",
              ( (entry and entry.target) ? " [ #{entry.target.try(:title)} ] " : " [ #{entry.url if not entry.url.blank?} ] " )
            ].join.html_safe
          end
          div_content << content_tag(:div, class: 'pull-right') do
            menu_content = []
            menu_content << link_to(icon('edit', text: ''), edit_site_admin_menu_menu_item_path(entry.menu_id, entry.id), title: t("edit")) if test_permission(:menu_items, :edit)
            menu_content << link_to(icon('trash', text: ''), site_admin_menu_menu_item_path(entry.menu_id, entry.id), method: :delete, data: {confirm: t('are_you_sure')}, title: t("destroy")) if test_permission(:menu_items, :destroy)
            menu_content << link_to(icon('move', text: ''),"#", class: 'handle', title: t("move")) if test_permission(:menu_items, :change_position)
            menu_content << link_to("+", new_site_admin_menu_menu_item_path(entry.menu_id, parent_id: entry.id), class: "btn btn-success btn-xs", title: t("add_sub_menu")) if test_permission(:menu_items, :new)
            menu_content.join.html_safe
          end
          div_content.join.html_safe
        end
      else
        title_link
      end
      li_content << content_tag(:menu, class: 'submenu') do
        sons[entry.id].map do |child|
          print_menu_entry(sons, child, view_ctrl)
        end.join.html_safe
      end if has_submenu
      li_content.join.html_safe
    end
  end
  private :print_menu_entry

  # Define mensagens personalizadas
  def flash_message
    "".tap do |messages|
      [:info, :warning, :error, :success, :notice, :alert].each do |type|
        if flash[type]
          css = :success if type == :notice 
          css = :error   if type == :alert 

          messages << content_tag('div', :class => "alert alert-#{css}") do
            raw %{
              #{link_to(raw('&times;'), '#', class: 'close', data: {dismiss: "alert"})}
              #{flash.now[type]}
            }
          end
          # Limpa a mensagem
          flash[type] = nil
        end
      end
    end
  end

  def with_permission(args = {}, &block)
    args.reverse_merge!({
      controller: controller.class,
      action: controller.action_name
    })
    block.call if check_permission(args[:controller], args[:action])
  end

  # Verifica se o usuário tem permissão no controlador e na ação passada como parâmetro
  # Parâmetros: (Objeto) ctrl, (array) actions, Objeto site (opcional)
  # Retorna: verdadeiro ou falso
  def check_permission(ctrl, actions)
    actions = [actions] unless actions.is_a? Array
    actions.each do |action|
      if test_permission(ctrl.controller_name, action)
        return true
      end
    end
    return false
  end

  # Monta o menu baseado nas permissões do usuário
  # Parametros: objeto
  def make_menu(obj, args={})
    #não criar menu para objetos de outro site
    return "" if obj.respond_to?(:site_id) and obj.site_id != current_site.id
    
    raw("".tap do |menu|
      excepts = args[:except] || []
      ctrl = args[:controller] || controller.class

      # Texto nos ícones
      args[:with_text] = true if args[:with_text].nil?

      # Transforma o parâmetro em array caso não seja
      excepts = [excepts] unless excepts.is_a? Array
      excepts.each_index do |i|
        # Transforma parâmetros em símbolos caso não sejam
        excepts[i] = excepts[i].to_sym unless excepts[i].is_a? Symbol
      end

      (ctrl.instance_methods(false) - excepts).each do |action|
        if test_permission(ctrl, action)
          case action.to_sym
          
          when :show
            menu << link_to(
              icon('eye-open', text: args[:with_text] ? t('show') : ''),
              params.merge({
                :controller => ctrl.controller_name,
                :action => 'show', :id => obj.id
              }),
              :alt => t('show'),
              :title => t('show')
            ) + " "

          when :edit
            menu << link_to(
              icon('edit', text: args[:with_text] ? t('edit') : ''),
              params.merge({
                :controller => ctrl.controller_name,
                :action => 'edit', :id => obj.id
              }),
              :alt => t('edit'),
              :title => t('edit')) + " "

          when :destroy
            menu << link_to(
              icon('trash', text: args[:with_text] ? t('destroy') : ''),
              params.merge({
                :controller => ctrl.controller_name,
                :action => 'destroy',
                :id => obj.id
              }),
              :data => {:confirm => t('are_you_sure')},
              :method => :delete,
              :alt => t('destroy'),
              :title => t('destroy')) + " "
          end
        end
      end
    end)
  end

  def recycle_bin_actions resource, options={}
    ''.tap do |html|
      if test_permission controller_name, :purge
        html << link_to(icon('trash', text: options[:with_text] ? t('destroy') : nil),
          options.merge({action: 'show', id: resource.id}), :title => t("purge"), method: 'delete', confirm: t('are_you_sure'))
      end
      if test_permission controller_name, :recover
        html << link_to(icon('refresh', text: options[:with_text] ? t('recover') : nil),
          options.merge({action: 'recover', id: resource.id}), :title => t("recover"), method: 'put')
      end
    end.html_safe
  end

  # Método para ordenar tabelas pela coluna
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    icon_name = column == sort_column ? sort_direction == "asc" ? "chevron-up" : "chevron-down" : nil
    link_to "#{title}#{icon(icon_name)}".html_safe,
      #quando uma lista é reordenada, ela volta para a página 1
      params.merge({sort: column, direction: direction, page: 1}),
      data: { column: column},
      remote: true,
      class: "sortable #{css_class}"
  end

  # Informações sobre paginação
  def info_page(collection, style = nil)
    if collection.page(1).count > 0
      html = "#{t('views.pagination.displaying')} #{collection.offset_value + 1} - 
      #{collection.offset_value + collection.length}"
      html << " #{t('of')} #{collection.total_count}" 

      content_tag :div, html, :class => "pagination", :style => style
    end
  end

  # Links para selecionar a quantidade de itens por página
  def per_page_links(collection, remote = false, size = nil)
    if collection.page(1).count > per_page_array.first.to_i
      html = "<li><span>#{t('views.pagination.per_page')} </span></li>"

      params[:per_page] = per_page_default if params[:per_page].blank?

      per_page_array.each do |item|
        html << 
        if params[:per_page].to_i == item.to_i
          content_tag :li, :class => 'page active' do
            #link_to "#{item} ", params.merge({:per_page => item, :page => 1}), :remote => remote
            content_tag :span, item
          end
        else
          content_tag(:li, :class => 'page') do
            link_to "#{item} ", params.merge({:per_page => item, :page => 1}), :remote => remote
          end
        end
      end

      content_tag :div do
        content_tag :ul, :class => "pagination#{" pagination-#{size}" if size}"  do
          raw(html)
        end
      end
    end
  end

  # Cria array de itens por página
  def per_page_array
    per_page_string.gsub(/[^\d,]/,'').
      split(',').uniq.
      sort {|a,b| a.to_i <=> b.to_i}
  end

  # Quantidade de registro por página padrão
  def per_page_default
    if @site
      ( @site.try(:per_page_default) || 
       Site.columns_hash['per_page_default'].try(:default) ).to_i
    else
      current_settings.per_page_default.try(:to_i)
    end
  end

  # Pega string de itens por página
  # Ordem: Site, Valor Padrão da coluna, valor fixo.
  def per_page_string
    if @site
      ( @site.try(:per_page) || Site.columns_hash['per_page'].default ) << 
      ",#{per_page_default}"
    else
      "#{current_settings.per_page},#{per_page_default}"
    end
  end

  def main_sites_list curr_site
    Site.where(parent_id: nil).order('name') - [curr_site]
  end

  def content_tag_if(condition, tag_name, options = {}, &block)
    content_tag(tag_name, options, &block) if condition 
  end

  def title title, raw_text=false
    content_for :title, raw_text ? title : t(title)
  end

  def period_dates(inidate, findate, force_show_year = true)
    html = ""
    if not findate
      html << period_date_and_hour(inidate, force_show_year)
    else
      if(inidate.month == findate.month)
        html << "#{l(inidate, format: (force_show_year || inidate.year!=Time.now.year) ? :event_period_full : :event_period_short, iniday: inidate.strftime('%d'), finday: findate.strftime('%d'))}"
      else
        html << period_date_and_hour(inidate, force_show_year)
        html << " #{t('time.period_separator')} "
        html << period_date_and_hour(findate, force_show_year)
      end
    end
    raw html
  end

  def period_date_and_hour(date, force_show_year = true)
    html = ""
    if(date.nil?)
      html << "#{t('no_event_period')}"
    else
      html << "#{l(date, format: (force_show_year || date.year!=Time.now.year) ? :event_date_full : :event_date_short)}"
      if(date.hour != 0)
        html << " #{l(date, format: :event_hour)}"
      end
    end
    html
  end
  private :period_date_and_hour

  def icon(type, args={})
    args.reverse_merge({
      :white => false,
      :text  => ''
    })

    unless type.nil?
      icon_class = "glyphicon glyphicon-#{type}" + (args[:white] ? ' glyphicon-white' : '')

      if args[:right]
        raw "#{args[:text]} <i class='#{icon_class}'></i>"
      else
        raw "<i class='#{icon_class}'></i> #{args[:text]}"
      end
    end
  end

  def login_protocol
    current_settings.login_protocol
  end

  #Método utilizado para ativar a aba de login ou de cadastro.
  def active_tab(tab)
    if request.path.include?(tab)
      "active"
    else
      ""
    end
  end

  def site_avatar_tag site=current_site, size=32
    repository = Repository.find_by_id(site.top_banner_id)
    if repository
      weby_file_view(repository, :mini, size, size,
                      { as: 'link',
                        title: site.description,
                        url: main_app.site_url(subdomain: site)
                      })
    else
      link_to image_tag('weby-filler.png', style: "width: #{size}px; height: #{size}px;"), main_app.site_url(subdomain: site)
    end
  end

  #URL do login de acordo com o site.
  #O login pode ser na url global ou na url do próprio site
  def weby_login_url back_url=nil
    site = nil
    if Weby::Settings.domain.present? and current_site
      unless request.host.match(Weby::Settings.domain)
        site = current_site
      end
    end

    main_app.login_url(
      subdomain: site,
      protocol: login_protocol,
      back_url: back_url
    )
  end

  # refactored

  ##
  # Helper to print checkboxes showing status for fields setted in parameter.
  # When user has permission to change this field, is generated one link
  # to access the action setted in parameters or by defautl 'toggle' action.

  # TODO usar named parameters do ruby 2.
  def toggle_field(resource, field, action = 'toggle', options = {})
    ''.tap do |html|
      title = resource[field] ? t('enable') : t('disable')
      options[:id] ||= resource.id

      check_box_options = {
        alt: title,
        title: title,
        class: 'toggle'
      }

      link_options = options.merge({
        method: :put,
        alt: title,
        title: title
      })

      url_options = options.merge({
        action: action,
        id: options[:id],
        field: field
      })
      if test_permission (options[:controller] || controller_name), action
        checkbox = check_box_tag(field, resource[field], resource[field], check_box_options)
        html << link_to(checkbox, url_options, link_options)
      else
        check_box_options = check_box_options.merge({disabled: true})
        html << check_box_tag(field, resource[field], resource[field], check_box_options)
      end
    end
  end
end
