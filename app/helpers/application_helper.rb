# coding: utf-8
module ApplicationHelper
  def session_user
    @session_user ||= User.find(session[:user])
  end

  def is_in_admin_context?
    request.path.split('/').first(3).include?('admin')
  end

  def is_in_profile_context?
    paths = request.path.split('/').first(2)
    paths.include?('profiles') || paths.include?('notifications')
  end

  def is_in_sites_index?
    (request.path == '/' || request.path.match(/^\/sites\/page\/\d+/)) && !current_site
  end

  def not_in_site_context?
    !current_site || is_in_admin_context? || is_in_profile_context? || is_in_sites_index?
  end

  # Define the menus
  # Params: Menu's list (sons, view_ctrl=false)
  # html_class: "dropdown" or "expanded"
  # Returns: the menu with its controllers
  def print_menu(menu, view_ctrl: false, html_class: 'expanded')
    return '' unless menu
    menuitems = menu.items_by_parent(!view_ctrl)
    content_tag :menu, class: html_class do
      menuitems.fetch(nil, []).map do |child|
        print_menu_entry(menuitems, child, view_ctrl)
      end.join.html_safe
    end
  end

  # Recursive methods in order to generate submenus and controles
  def print_menu_entry(sons, entry, view_ctrl)
    has_submenu = sons[entry.id].present?
    is_current_page = (@page && @page == entry.target) || request.path == entry.url
    item_class = entry.html_class.present? ? [entry.html_class] : []
    item_class << 'sub' if has_submenu
    item_class << 'current_page' if is_current_page

    content_tag :li, id: "menu_item_#{entry.id}", class: item_class.join(' ') do
      title_link = link_to(entry.title,
                           entry.target_id.to_i > 0 ? main_app.site_page_path(entry.target_id) : entry.url,
                           alt: entry.title, title: entry.description, target: entry.new_tab ? '_blank' :  '')

      li_content = []
      li_content << content_tag(:div, '', class: 'hierarchy') if view_ctrl
      li_content << if view_ctrl
        content_tag(:div, style: 'min-height: 25px', class: "menuitem-ctrl#{' deactivated' unless entry.publish}") do
          div_content = []
          div_content << content_tag(:span) do
            [
              toggle_field(entry, 'publish', 'toggle', controller: 'sites/admin/menus/menu_items', menu_id: entry.menu_id),
              " #{title_link}",
              ( (entry and entry.target) ? " [ #{entry.target.try(:title)} ] " : " [ #{entry.url unless entry.url.blank?} ] ")
            ].join.html_safe
          end
          div_content << content_tag(:div, class: 'pull-right') do
            menu_content = []
            menu_content << link_to(icon('edit', text: ''), edit_site_admin_menu_menu_item_path(entry.menu_id, entry.id), title: t('edit')) if test_permission(:menu_items, :edit)
            menu_content << link_to(icon('trash', text: ''), site_admin_menu_menu_item_path(entry.menu_id, entry.id), method: :delete, data: { confirm: t('are_you_sure') }, title: t('destroy')) if test_permission(:menu_items, :destroy)
            menu_content << link_to(icon('move', text: ''), '#', class: 'handle', title: t('move')) if test_permission(:menu_items, :change_position)
            menu_content << link_to('+', new_site_admin_menu_menu_item_path(entry.menu_id, parent_id: entry.id), class: 'btn btn-success btn-xs', title: t('add_sub_menu')) if test_permission(:menu_items, :new)
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

  # Defines custom messages
  def flash_message
    ''.tap do |html|
      flash.each do |key, value|
        html << content_tag('blockquote', class: flash_class(key)) do
          raw %(
            #{link_to('&times;'.html_safe, '#', class: 'close', data: { dismiss: 'alert' }, 'aria-hidden' => true)}
            #{value}
          )
        end
      end
      flash.clear
    end.html_safe
  end

  def flash_class(type)
    case type
    when 'info' then 'alert-info'
    when 'notice', 'success' then 'alert-success'
    when 'error', 'alert' then 'alert-danger'
    when 'warning' then 'alert-warning'
    else 'alert-info'
    end
  end

  def with_permission(args = {}, &block)
    args.reverse_merge!(
      controller: controller.class,
      action: controller.action_name
    )
    block.call if check_permission(args[:controller], args[:action])
  end

  # Verifies if the user have an permition on the specified controller and action
  # Params: (Object) ctrl, (array) actions
  # Returns: true or false
  def check_permission(ctrl, actions)
    actions = [actions] unless actions.is_a? Array
    actions.each do |action|
      if test_permission(ctrl.controller_name, action)
        return true
      end
    end
    false
  end

  # Creates the menu based on user's permitions
  # Params: object, args={TODO}
  def make_menu(obj, args = {})
    # in order to not create an menu with objects form another site
    return '' if obj.respond_to?(:site_id) and obj.site_id != current_site.id

    raw(''.tap do |menu|
      excepts = args[:except] || []
      ctrl = args[:controller] || controller.class

      # Icon's texts
      args[:with_text] = true if args[:with_text].nil?

      # Transforms the param in array if it is not one
      excepts = [excepts] unless excepts.is_a? Array
      excepts.each_index do |i|
        # Transforms the params in symbols if they are not
        excepts[i] = excepts[i].to_sym unless excepts[i].is_a? Symbol
      end

      (ctrl.instance_methods(false) - excepts).each do |action|
        if test_permission(ctrl, action)
          case action.to_sym

          when :show
            menu << link_to(
              icon('eye-open', text: args[:with_text] ? t('show') : ''),
              params.merge(
                controller: ctrl.controller_name,
                action: 'show', id: obj.id
              ),
              alt: t('show'),
              title: t('show'),
              class: 'action-link'
            ) + ' '

          when :edit
            menu << link_to(
              icon('edit', text: args[:with_text] ? t('edit') : ''),
              params.merge(
                controller: ctrl.controller_name,
                action: 'edit', id: obj.id
              ),
              alt: t('edit'),
              title: t('edit'),
              class: 'action-link') + ' '

          when :destroy
            menu << link_to(
              icon('trash', text: args[:with_text] ? t('destroy') : ''),
              params.merge(
                controller: ctrl.controller_name,
                action: 'destroy',
                id: obj.id
              ),
              data: { confirm: t('are_you_sure') },
              method: :delete,
              alt: t('destroy'),
              title: t('destroy'),
              class: 'action-link') + ' '
          end
        end
      end
    end)
  end

  def recycle_bin_actions(resource, options = {})
    ''.tap do |html|
      if test_permission controller_name, :purge
        html << link_to(icon('trash', text: options[:with_text] ? t('destroy') : nil),
                        options.merge(action: 'show', id: resource.id), title: t('purge'), class: 'action-link', method: 'delete', confirm: t('are_you_sure'))
      end
      if test_permission controller_name, :recover
        html << link_to(icon('refresh', text: options[:with_text] ? t('recover') : nil),
                        options.merge(action: 'recover', id: resource.id), title: t('recover'), class: 'action-link', method: 'put')
      end
    end.html_safe
  end

  # Order tables by its column
  # TODO
  # TODO
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == 'asc') ? 'desc' : 'asc'
    icon_name = column == sort_column ? sort_direction == 'asc' ? 'chevron-up' : 'chevron-down' : nil
    link_to "#{title}#{icon(icon_name)}".html_safe,
            # when we reorder an list it goes back to the first page
            params.merge(sort: column, direction: direction, page: 1),
      data: { column: column },
      remote: true,
      class: "sortable #{css_class}"
  end

  # Pagination's informations
  # TODO refatorar isso aqui, antes fazia collection.page(1).count mudei para
  # collection.page(1).length para poder trabalhar com querys usando group
  def info_page(collection, style = nil)
    if collection.page(1).length > 0
      html = "#{t('views.pagination.displaying')} #{collection.offset_value + 1} -
      #{collection.offset_value + collection.length}"
      html << " #{t('of')} #{collection.total_count}"

      content_tag :div, html, class: 'pagination', style: style
    end
  end

  # Generate links in order to select the amount of intes per page
  def per_page_links(collection, remote = false, size = nil)
    if collection.page(1).length > per_page_array.first.to_i
      html = "<li><span>#{t('views.pagination.per_page')} </span></li>"

      params[:per_page] = per_page_default if params[:per_page].blank?

      per_page_array.each do |item|
        html <<
        if params[:per_page].to_i == item.to_i
          content_tag :li, class: 'page active' do
            # link_to "#{item} ", params.merge({per_page: item, page: 1}), remote: remote
            content_tag :span, "#{item} "
          end
        else
          content_tag(:li, class: 'page') do
            link_to "#{item} ", params.merge(per_page: item, page: 1), remote: remote
          end
        end
      end

      content_tag :div do
        content_tag :ul, class: "pagination#{" pagination-#{size}" if size}"  do
          raw(html)
        end
      end
    end
  end

  # Creates an array of itens per page
  def per_page_array
    per_page_string.gsub(/[^\d,]/, '').
      split(',').uniq.
      sort { |a, b| a.to_i <=> b.to_i }
  end

  # Default amount of registers per pages
  def per_page_default
    if @site
      ( @site.try(:per_page_default) ||
       Site.columns_hash['per_page_default'].try(:default)).to_i
    else
      current_settings.per_page_default.try(:to_i)
    end
  end

  # Pega string de itens por página
  # Ordem: Site, Valor Padrão da coluna, valor fixo.
  def per_page_string
    if @site
      ( @site.try(:per_page) || Site.columns_hash['per_page'].default) <<
      ",#{per_page_default}"
    else
      "#{current_settings.per_page},#{per_page_default}"
    end
  end

  def main_sites_list(curr_site)
    Site.where(parent_id: nil).order('name') - [curr_site]
  end

  def content_tag_if(condition, tag_name, options = {}, &block)
    content_tag(tag_name, options, &block) if condition
  end

  def title(title, raw_text = false)
    content_for :title, raw_text ? title : t(title)
  end

  def period_dates(inidate, findate, force_show_year = true)
    html = ''
    if not findate
      html << period_date_and_hour(inidate, force_show_year)
    else
      if (inidate.month != findate.month) || (inidate.year != findate.year)
        html << period_date_and_hour(inidate, force_show_year)
        html << " #{t('time.period_separator')} "
        html << period_date_and_hour(findate, force_show_year)
      else
        html << "#{l(inidate, format: (force_show_year || inidate.year != Time.now.year) ? :event_period_full : :event_period_short, iniday: inidate.strftime('%d'), finday: findate.strftime('%d'))}"
      end
    end
    raw html
  end

  def period_date_and_hour(date, force_show_year = true)
    html = ''
    if date.nil?
      html << "#{t('no_event_period')}"
    else
      html << "#{l(date, format: (force_show_year || date.year != Time.now.year) ? :event_date_full : :event_date_short)}"
      if (date.hour != 0)
        html << " #{l(date, format: :event_hour)}"
      end
    end
    html
  end
  private :period_date_and_hour

  # Generate icons
  # TODO:
  # TODO:
  def icon(type, args = {})
    args.reverse_merge(
      white: false,
      text: ''
    )

    unless type.nil?
      ico = not_in_site_context? ?  'glyphicon' : 'icon'
      icon_class = "#{ico} #{ico}-#{type}" + (args[:white] ? " #{ico}-white" : '')

      if args[:right]
        raw "#{args[:text]} <i class='#{icon_class}' style='#{args[:icon_style]}'></i>"
      else
        raw "<i class='#{icon_class}' style='#{args[:icon_style]}'></i> #{args[:text]}"
      end
    end
  end

  delegate :login_protocol, to: :current_settings

  # Used to activate login/register tab
  def active_tab(tab)
    if request.path.include?(tab)
      'active'
    else
      ''
    end
  end

  def site_avatar_tag(site = current_site, size = 32)
    repository = Repository.find_by_id(site.top_banner_id)
    if repository
      weby_file_view(repository, :i, size, size,
                     as: 'link',
                     title: site.description,
                     url: main_app.site_url(subdomain: site)
                     )
    else
      link_to image_tag('weby-filler.png', style: "width: #{size}px; height: #{size}px;"), main_app.site_url(subdomain: site)
    end
  end

  # Login's URL according to the site.
  # O login pode ser na url global ou na url do próprio site
  def weby_login_url(back_url = nil)
    site = nil
    if Weby::Settings.domain.present? && current_site
      site = current_site unless request.host.match(Weby::Settings.domain)
    end

    main_app.login_url(
      subdomain: site,
      protocol: login_protocol,
      back_url: back_url
    )
  end

  def search_input(value, options = {})
    placeholder = options[:placeholder] || t('search')
    button_class = 'btn btn-info btn-search'
    button_class << ' ' + options[:button_class] if options[:button_class]
    content_tag :div, class: 'input-group' do
      concat search_field_tag(:search, value, class: 'form-control', placeholder: placeholder)
      concat(
        content_tag(:span, class: 'input-group-btn') do
          button_tag(icon('search', white: true, icon_style: 'width: 32px'), type: 'submit', class: button_class, title: t('search'))
        end
      )
    end
  end

  # refactored

  ##
  # Helper to print checkboxes showing status for fields setted in parameter.
  # When user has permission to change this field, is generated one link
  # to access the action setted in parameters or by defautl 'toggle' action.

  # TODO use named parameters from ruby 2.
  def toggle_field(resource, field, action = 'toggle', options = {})
    ''.tap do |html|
      title = resource[field] ? t('enable') : t('disable')
      options[:id] ||= resource.id

      check_box_options = {
        alt: title,
        title: title,
        class: 'toggle'
      }

      link_options = options.merge(
        method: :put,
        alt: title,
        title: title
      )

      url_options = options.merge(
        action: action,
        id: options[:id],
        field: field
      )
      if test_permission (options[:controller] || controller_name), action
        checkbox = check_box_tag(field, resource[field], resource[field], check_box_options)
        html << link_to(checkbox, url_options, link_options)
      else
        check_box_options = check_box_options.merge(disabled: true)
        html << check_box_tag(field, resource[field], resource[field], check_box_options)
      end
    end
  end

  # Input: Site object  
  # Output: link to the favicon
  def favicon(site)
    site.favicon.nil? ? asset_url('favicon.ico') : main_app.site_url(subdomain: site) + site.favicon.archive.url
  end
end
