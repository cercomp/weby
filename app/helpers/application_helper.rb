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
    content_tag :ul, class: ['menu-res', html_class], role: :menu do
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
      li_content = []
      li_content << content_tag(:div, '', class: 'hierarchy') if view_ctrl
      li_content << if view_ctrl
        content_tag(:div, style: 'min-height: 25px', class: "menuitem-ctrl#{' deactivated' unless entry.publish}") do
          div_content = []
          div_content << link_to(image_tag('drag.png'), '#', class: 'handle', title: t('move')) if test_permission(:menu_items, :change_position)
          div_content << check_box_tag(:select_item, entry.id, false, class: 'sel-item')
          div_content << content_tag(:span, content_tag(:span), class: 'disclose')
          div_content << toggle_field(entry, 'publish', 'toggle', controller: 'sites/admin/menus/menu_items', menu_id: entry.menu_id, remote: true, class: 'toggle-menu-item')
          div_content << content_tag(:span, class: 'menu-entry') do
            link_text = if entry && entry.target
              content_tag(:span, "#{entry.target.class.model_name.human} [#{link_to entry.target.title, [entry.target_namespace, entry.target]}]".html_safe)
            else
              content_tag(:span, entry.url.blank? ? '#' : entry.url)
            end
            [
              menu_item_link(entry, entry.url.present? && entry.url != '#' && !entry.url.match(/^javascript:/)),
              #content_tag(:span, "[", class: 'link-text-open'),
              content_tag(:span, link_text, class: 'link-text', title: entry&.url),
              #content_tag(:span, " ]", class: 'link-text-close')
            ].join(' ').html_safe
          end
          div_content << content_tag(:div, class: 'pull-right align-middle') do
            menu_content = []
            menu_content << link_to(image_tag('add-row-w.svg'), new_site_admin_menu_menu_item_path(entry.menu_id, parent_id: entry.id), class: 'btn btn-success btn-sm add-subitem', title: t('add_sub_menu')) if test_permission(:menu_items, :new)
            menu_content << render_dropdown_menu do
              dropdown_menu = []
              dropdown_menu << link_to(fa_icon('files-o', text: t('copy')), new_site_admin_menu_menu_item_path(entry.menu_id, copy_from: entry.id)) if test_permission(:menu_items, :new)
              dropdown_menu << link_to(icon('edit', text: t('edit')), edit_site_admin_menu_menu_item_path(entry.menu_id, entry.id), title: t('edit')) if test_permission(:menu_items, :show)
              dropdown_menu << link_to(icon('trash', text: t('destroy')), site_admin_menu_menu_item_path(entry.menu_id, entry.id), method: :delete, data: { confirm: t('are_you_sure_del_item', item: entry.title) }, title: t('destroy')) if test_permission(:menu_items, :destroy)
              dropdown_menu.join.html_safe
            end
            menu_content.join.html_safe
          end
          div_content.join.html_safe
        end
      else
        menu_item_link(entry)
      end
      li_content << content_tag(:ul, class: 'menu-res submenu') do
        sons[entry.id].map do |child|
          print_menu_entry(sons, child, view_ctrl)
        end.join.html_safe
      end if has_submenu
      li_content.join.html_safe
    end
  end
  private :print_menu_entry

  def target_url obj, opts={}
    case obj.target
    when Page
      site_page_path(obj.target)
    when Journal::News
      news_path(obj.target)
    when Calendar::Event
      event_path(obj.target)
    else
      obj.url.present? ? obj.url : (opts[:js_fallback] ? 'javascript:void(0);' : nil)
    end
  end

  def menu_item_link menu_item, force_new_tab=false
    url = target_url(menu_item, js_fallback: true)
    is_empty = url.blank? || url.to_s == '#' || url.match(/^javascript:/)
    link_to(menu_item.title, url,
      role: is_empty ? 'button' : nil,
      title: menu_item.description,
      target: menu_item.new_tab || force_new_tab ? '_blank' :  '',
      class: [is_empty ? 'empty-href' : nil, translate_class(menu_item)].compact
    )
  end

  # Defines custom messages
  def flash_message(modal: false)
    if modal
      modal_html = <<-EOS
        <div class='modal fade' id='message' tabindex='-1' role='dialog' aria-labelledby='myModalLabel' aria-hidden='false'>
          <div class='modal-dialog'>
            <div class='modal-content'>
              <div class='modal-header'>
                <h4 class='modal-title' id='myModalLabel'>#{t('message')}</h4>
              </div>
              <div class='modal-body'>
                <div class='alert alert-warning'>
                  #{flash[:success]}
                </div>
              </div>
              <div class='modal-footer'>
                <button type='button' class='btn btn-default' data-dismiss='modal'>#{t('close')}</button>
              </div>
            </div>
          </div>
        </div>
      EOS
      if not flash.blank?
        modal_js = <<-EOS
          <script>
            document.addEventListener('DOMContentLoaded', function() {
              $('#message').modal('show');
            });
          </script>
        EOS
      end
    end

    ''.tap do |html|
      flash.each do |key, value|
        html << modal_html if modal_html
        html << modal_js if modal_js
        html << content_tag('blockquote', class: "flash-alert #{flash_class(key)}") do
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
    return '' if obj.respond_to?(:site_id) && obj.site_id != current_site.id

    excepts = args[:except] || []
    ctrl = args[:controller] || controller.class

    # Icon's texts
    args[:with_text] = true if args[:with_text].nil?

    # Transforms the param in array if it is not one
    excepts = [excepts] unless excepts.is_a? Array
    excepts.each_index do |i|
      # Transforms the params in symbols if they are not
      excepts[i] = excepts[i].to_sym unless excepts[i].is_a?(Symbol)
    end

    methods = ctrl.instance_methods(false) - excepts
    menus = []
    ## show
    if methods.include?(:show) && test_permission(ctrl, :show)
      menus << link_to(
        icon('eye-open', text: args[:with_text] ? t('show') : ''),
        {
          controller: ctrl.controller_name,
          action: 'show',
          id: obj.id
        }.merge(args.fetch(:params, {})),
        alt: t('show'),
        title: t('show'),
        class: 'action-link'
      )
    end
    ## Edit
    if methods.include?(:edit) && test_permission(ctrl, :edit)
      menus << link_to(
        icon('edit', text: args[:with_text] ? t('edit') : ''),
        {
          controller: ctrl.controller_name,
          action: 'edit', id: obj.id
        }.merge(args.fetch(:params, {})),
        alt: t('edit'),
        title: t('edit'),
        class: 'action-link'
      )
    end
    # Newsletter
    if methods.include?(:newsletter) && test_permission(ctrl, :newsletter)
      @newsletter ||= current_skin.components.find_by(name: 'newsletter', publish: true)
      if @newsletter.present?
        menus << link_to(
          icon(Journal::NewsletterHistories.sent(current_site.id, obj.id).count == 0 ? 'envelope' : 'ok', text: args[:with_text] ? t('.newsletter') : ''),
          {
            controller: ctrl.controller_name,
            action: 'newsletter', id: obj.id
          },
          alt: t('letter'),
          title: t('letter'),
          class: 'action-link'
        )
      end
    end
    # Destroy
    if methods.include?(:destroy) && test_permission(ctrl, :destroy)
      menus << link_to(
        icon('trash', text: args[:with_text] ? t('destroy') : ''),
        {
          controller: ctrl.controller_name,
          action: 'destroy',
          id: obj.id
        }.merge(args.fetch(:params, {})),
        data: { confirm: t('are_you_sure_del_item', item: obj.screen_name) },
        method: :delete,
        alt: t('destroy'),
        title: t('destroy'),
        class: 'action-link'
      )
    end
    menus.join(' ').html_safe
  end

  def recycle_bin_actions(resource, options = {})
    ''.tap do |html|
      if test_permission controller_name, :purge
        html << link_to(icon('trash', text: options[:with_text] ? t('destroy') : nil),
                        options.merge(action: 'show', id: resource.id), title: t('purge'), class: 'action-link', method: 'delete', data: {confirm: t('are_you_sure_del_item', item: resource.screen_name)})
      end
      if test_permission controller_name, :recover
        html << link_to(icon('refresh', text: options[:with_text] ? t('recover') : nil),
                        options.merge(action: 'recover', id: resource.id), title: t('recover'), class: 'action-link', method: 'put')
      end
    end.html_safe
  end

  def append_url_params _params
    [:status_filter, :search, :mime_type, :begin_at, :end_at]
      .map{|key| [key, params[key]] }
      .to_h
      .merge(_params)
  end

  # Order tables by its column
  # TODO
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == 'asc') ? 'desc' : 'asc'
    icon_name = column == sort_column ? sort_direction == 'asc' ? 'arrow-up' : 'arrow-down' : 'sort'
    link_to "#{title}#{icon(icon_name)}".html_safe,
            # when we reorder an list it goes back to the first page
            append_url_params({sort: column, direction: direction, page: 1}),
      data: { column: column },
      remote: true,
      style: "white-space:nowrap;",
      class: "sortable #{css_class}"
  end

  # Pagination's informations
  # TODO refatorar isso aqui, antes fazia collection.page(1).count mudei para
  # collection.page(1).length para poder trabalhar com querys usando group
  def info_page(collection, style = nil)
    if collection.length > 0
      html = "#{t('views.pagination.displaying')} #{collection.offset_value + 1} -
      #{collection.offset_value + collection.length}"
      html << " #{t('of')} #{collection.total_count}"

      content_tag :div, html, class: 'pagination', style: style
    end
  end

  # Generate links in order to select the amount of intes per page
  def per_page_links(collection, remote = false, size = nil)
    if collection.length >= per_page_array.first.to_i || params[:page].to_i > 1
      html = "<li><span>#{t('views.pagination.per_page')} </span></li>"

      params[:per_page] = per_page_default if params[:per_page].blank?

      per_page_array.each do |item|
        html <<
        if params[:per_page].to_i == item.to_i
          content_tag :li, class: 'page active' do
            content_tag :span, "#{item} "
          end
        else
          content_tag(:li, class: 'page') do
            link_to "#{item} ", append_url_params({per_page: item, page: 1}), remote: remote
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

  def content_tag_if(condition, tag_name, options = {}, &block)
    content_tag(tag_name, options, &block) if condition
  end

  def title(title, raw_text = false)
    content_for :title, raw_text ? title : t(title)
  end

  def meta_image(repository)
    repository = Repository.find(repository) if repository.is_a? Integer
    return unless repository
    content_for :meta_images, "<meta property=\"og:image\" content=\"#{asset_url(repository.archive.url(:o))}\" /><meta property=\"og:type\" content=\"article\" />".html_safe
  end

  def add_meta_tags(obj)
    if obj.respond_to?(:title)
      title(obj.title, true)
    elsif obj.respond_to?(:name)
      title(obj.name, true)
    end
    if obj.respond_to?(:image)
      meta_image(obj.image)
    end
    if obj.respond_to?(:summary)
      content_for :description, strip_tags(obj.summary.to_s).first(280)
    elsif obj.respond_to?(:information)
      content_for :description, strip_tags(obj.information.to_s).first(280)
    elsif obj.respond_to?(:text)
      content_for :description, strip_tags(obj.text.to_s).first(280)
    end
  end

  def period_dates(event, force_show_year = true, full = false)
    inidate, findate = event.begin_at, event.end_at
    html = ''
    if findate
      #show_full = full && (inidate.strftime('%H:%M')!='00:00' || findate.strftime('%H:%M')!='00:00')
      if inidate.month != findate.month || inidate.year != findate.year #|| show_full
        html << period_date_and_hour(inidate, force_show_year)
        html << " #{t('time.period_separator')} "
        html << period_date_and_hour(findate, force_show_year)
      else
        if event.same_date?
          html << "#{l(inidate, format: (force_show_year || inidate.year != Time.current.year) ? :event_hour_period_full : :event_hour_period_short, inihour: l(inidate, format: :hour), finhour: l(findate, format: :hour))}"
        else
          html << "#{l(inidate, format: (force_show_year || inidate.year != Time.current.year) ? :event_period_full : :event_period_short, iniday: inidate.strftime('%d'), finday: findate.strftime('%d'))}"
        end
      end
    else
      html << period_date_and_hour(inidate, force_show_year)
    end
    html.html_safe
  end

  def period_date_and_hour(date, force_show_year = true)
    html = ''
    if date.nil?
      html << t('no_event_period')
    else
      html << "#{l(date, format: (force_show_year || date.year != Time.current.year) ? :event_date_full : :event_date_short)}"
      if date.strftime('%H:%M')!='00:00'
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
      ico = not_in_site_context? || args[:glyph] ?  'glyphicon' : 'icon'
      icon_class = "#{ico} #{ico}-#{type}" + (args[:white] ? " #{ico}-white" : '')

      if args[:right]
        raw "#{args[:text]} <i class=\"#{icon_class} #{args[:class]}\" style=\"#{args[:icon_style]}\"></i>"
      else
        raw "<i class=\"#{icon_class} #{args[:class]}\" style=\"#{args[:icon_style]}\"></i> #{args[:text]}"
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
    repository = Repository.find_by(id: site.top_banner_id)
    if repository
      weby_file_view(repository, :i, size, size,
                     as: 'link',
                     #title: site.description,
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
    if Weby::Settings::Weby.domain.present? && current_site
      site = current_site unless request.host.match(Weby::Settings::Weby.domain)
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
    is_active = !!resource.send(field.to_sym)
    ''.tap do |html|
      title = is_active ? t('enable') : t('disable')
      options[:id] ||= resource.id

      check_box_options = {
        alt: title,
        title: title
        #,class: 'toggle'
      }

      link_options = options.merge(
        method: :put,
        alt: title,
        title: title
      )

      url_options = options.except(:class, :data, :remote).merge(
        action: action,
        id: options[:id],
        field: field
      )
      # check if resource belongs to current site
      site_check = resource.respond_to?(:site_id) ? (current_site.blank? || resource.site_id == current_site.id) : true

      if test_permission(options[:controller] || controller_name, action) && site_check
        checkbox = render_toggle(field, true, is_active, check_box_options)
        html << link_to(checkbox, url_options, link_options)
      else
        check_box_options = check_box_options.merge(disabled: true)
        html << render_toggle(field, true, is_active, check_box_options)
      end
    end.html_safe
  end

  def render_toggle field, value, is_checked, options={}
    check_box_options = {class: 'toggle weby-toggle'}
    label_for = options[:id] || field.to_s.delete("]").tr("^-a-zA-Z0-9:.", "_")
    html = check_box_tag(field, value, is_checked, check_box_options.merge(options))
    html << content_tag(:label, content_tag(:span, '', class: 'check-handler'), class: 'check-trail', for: label_for)
  end

  def render_dropdown_menu options={}, &block
    direction = options[:direction] || 'bottom-left'
    content_tag :div, class: 'dropmic', role: 'navigation', data: {dropmic: '42', dropmic_direction: direction} do
      concat button_tag(icon('option-horizontal'), data: {dropmic_btn: ''})
      concat content_tag(:div, class: 'dropmic-menu', aria: {hidden: true}, &block)
    end
  end

  def render_bulk_actions &block
    content_tag(:div, class: 'bulk-actions sticky-bottom', style: 'height: 0') do
      content_tag(:div, class: 'bulk-actions-container') do
        concat content_tag(:small, t('selected_items'))
        concat capture(&block)
      end
    end
  end

  def unescape_param param
    # call it twice so %2B becomes + and then becomes ' 'space
    CGI.unescape(CGI.unescape(param.to_s))
  end

  # Input: Site object
  # Output: link to the favicon
  def favicon(site)
    return asset_url('favicon.ico') if site.favicon.nil?

    icon_url = site.favicon.archive.url
    icon_url.match(/https?\:\/\//) ? icon_url : "#{main_app.site_url(subdomain: site)}#{icon_url}"
  end
end
