#coding: utf-8
module ApplicationHelper
  def session_user
    @session_user ||= User.find(:first, :conditions => ['id = ?', session[:user]])
  end

  def is_in_admin_context?
    request.path.split('/').include?('admin')
  end

  # Alterna entre habilitar e desabilitar registro
  # Parâmetros: obj (Objeto), publish (Campo para alternar), action (Ação a ser executada no controller)
  # Campo com imagens V ou X para habilitar/desabilitar e degradê se não tiver permissão para alteração.
  def toggle_field(obj, field, action='toggle_field', options = {})
    ''.tap do |menu|
      if check_permission(controller.class, "#{action}")
        if obj[field.to_s] == 0 or not obj[field.to_s]
          menu << link_to( image_tag("false.png", :alt => t("disable")),
            {:action => "#{action}", :id => obj.id, :field => "#{field}"},
            options.merge({method: :put, :title => t("activate")}))
          menu << " #{t('unpublished')}" if options[:show_label]
        else
          menu << link_to(image_tag("true.png", :alt => t("enable")),
                          {:action => "#{action}", :id=> obj.id, :field => "#{field}"},
                          options.merge({method: :put, :title => t("deactivate")}))
          menu << " #{t('published')}" if options[:show_label]
        end
      else
        if obj[field.to_s] == 0 or not obj[field.to_s]
          menu << image_tag("false_off.png", :alt => t("enable"), :title => t("no_permission_to_activate_deactivate"))
          menu << " #{t('unpublished')}" if options[:show_label]
        else
          menu << image_tag("true_off.png", :alt => t("disable"), :title => t("no_permission_to_activate_deactivate"))
          menu << " #{t('published')}" if options[:show_label]
        end
      end
    end
  end

  # Define os menus
  # Parâmetros: Lista de menu (sons, view_ctrl=0)
  # html_class: "dropdown" ou "expanded"
  # Retorna: O menu com seus controles
  def print_menu(menu, view_ctrl=0, html_class="expanded")
    ''.tap do |menus|
      if menu
        menuitems = menu.items_by_parent
        menus << "\n<menu class=\"#{html_class}\">"
        if menuitems[0]
          menuitems[0].each do |child|
            menus << print_menu_entry(menuitems, child, view_ctrl, 1)
          end
        end
        menus << "\n</menu>\n"
      end
    end
  end

  # Método recursivo para gerar submenus e os controles
  def print_menu_entry(sons, entry, view_ctrl, indent=0)
    indent_space = " " * indent
    submenu = (not sons[entry.id].nil?) ? "class='sub'" : nil

    (view_ctrl == 1 ?
     "<li id=\"menu_item_#{entry.id}\" #{submenu}><div>" :
     "<li #{submenu}>").tap do |menus|
       #		if (entry.menu.try(:page_id).nil? and entry.menu.try(:link).empty?)
       #menus << "#{entry.menu.try(:title)}"
       #		else
       menus << link_to(entry.title, entry.target_id.to_i > 0 ? main_app.site_page_path(entry.target_id) : entry.url, :alt => entry.title,:title => entry.description, :target => entry.new_tab ? "_blank":"")
       #		end

       if view_ctrl == 1
         # Se existir um position nulo ele será organizado e todos do seu nível
         if entry.position.nil? or entry.position.to_i < 1 or entry.position.to_i > 2000
           sons[entry.parent_id].each_with_index do |item, idx|
             #menus << " (item.id:#{item.id} entry.id:#{entry.id} idx:#{idx+1}) " # Para debug
             if item.id == entry.id
               entry.update_attribute(:position, idx + 1)
               entry.position = idx + 1
             end
           end
         end
         #menus << " [ id:#{entry.id} pos:#{entry.position} ]" # Para debug
         menus << ( (entry and entry.target) ? " [ #{entry.target.try(:title)} ] " : " [ #{entry.url if not entry.url.blank?} ] " )
         menus << link_to(icon('edit', text: ''), edit_site_admin_menu_menu_item_path(entry.menu_id, entry.id), :title => t("edit"))
         menus << indent_space + link_to(icon('plus', text: ''), new_site_admin_menu_menu_item_path(entry.menu_id, :parent_id => entry.id), :title => t("add_sub_menu"))
         menus << indent_space + link_to(icon('trash', text: ''), site_admin_menu_menu_item_path(entry.menu_id, entry.id), :method=>:delete, :data => {:confirm => t('are_you_sure')}, :title => t("destroy"))
         menus << indent_space + link_to(icon('move', text: ''),"#", :class => 'handle', :title => t("move"))
      end
       menus << "\n" + indent_space + (view_ctrl == 1 ? "</div><menu>":"<menu>") unless submenu.nil?
       if sons[entry.id].class.to_s == "Array"
         sons[entry.id].each do |child|
           menus << print_menu_entry(sons, child, view_ctrl, indent+3)
         end
       end
       menus << "\n" + indent_space + " </menu>" unless submenu.nil?
       menus << "\n" + indent_space + "</li>" unless submenu.nil?
       menus << (view_ctrl == 1 ? "</div></li>":"</li>") if submenu.nil?
     end
  end

  # Define mensagens personalizadas
  def flash_message
    "".tap do |messages|
      [:info, :warning, :error, :success].each do |type|
        if flash[type]
          messages << content_tag('div', :class => "alert alert-#{type}") do
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
    if(obj.respond_to?(:site_id))
      #não criar menu para objetos de outro site
      return "" if obj.site_id != current_site.id
    end

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

  # Método para ordenar tabelas pela coluna
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title,
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

      content_tag :div, :class => "pagination#{" pagination-#{size}" if size}" do
        content_tag :ul, raw(html)
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
      current_settings[:per_page_default].try(:to_i) || 25
    end
  end

  # Pega string de itens por página
  # Ordem: Site, Valor Padrão da coluna, valor fixo.
  def per_page_string
    if @site
      ( @site.try(:per_page) || Site.columns_hash['per_page'].default ) << 
      ",#{per_page_default}"
    else
      ( current_settings[:per_page] || "5,15,30,60,100" ) <<
      ",#{per_page_default}"
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
      icon_class = "icon-#{type}" + (args[:white] ? ' icon-white' : '')

      if args[:right]
        raw "#{args[:text]} <i class='#{icon_class}'></i>"
      else
        raw "<i class='#{icon_class}'></i> #{args[:text]}"
      end
    end
  end

  def login_protocol
    current_settings[:login_protocol] || "http"
  end

  #Método utilizado para ativar a aba de login ou de cadastro.
  def active_tab(tab)
    if request.path.include?(tab)
      "active"
    else
      ""
    end
  end
end
