#coding: utf-8
module ApplicationHelper
  include SemanticFormHelper

  def session_user
    @session_user ||= User.find(:first, :conditions => ['id = ?', session[:user]])
  end

  # Alterna entre habilitar e desabilitar registro
  # Parâmetros: obj (Objeto), publish (Campo para alternar)
  # Campo com imagens V ou X para habilitar/desabilitar e degradê se não tiver permissão para alteração.
  def toggle_field(obj, field)
    menu = ""
    if current_user.is_admin
      if obj[field.to_s] == 0 or not obj[field.to_s]
        menu = link_to(image_tag("false.png", :alt => t("disable.masc")), {:action => "toggle_field", :id => obj.id, :field => "#{field}"}, :title => t("activate_deactivate"))
      else
        menu = link_to(image_tag("true.png", :alt => t("enable.masc")), {:action => "toggle_field", :id=> obj.id, :field => "#{field}"}, :title => t("activate_deactivate"))
      end
    else
      if obj[field.to_s] == 0 or not obj[field.to_s]
        menu = image_tag("false_off.png", :alt => t("enable.masc"), :title => t("no_permission_to_activate_deactivate"))
      else
        menu = image_tag("true_off.png", :alt => t("disable.masc"), :title => t("no_permission_to_activate_deactivate"))
      end
    end
    menu
  end

  # Define os menus
  # Parâmetros: Lista de menu (sons, view_ctrl=0)
  # Retorna: O menu com seus controles
  def print_menu(sons, view_ctrl=0)
    sons ||= ""
    menus ||= ""
    unless sons[0].nil?
      menus += "\n<menu>"
      sons[0].each do |child|
        menus += print_menu_entry(sons, child, view_ctrl, 1)
      end
      menus += "\n</menu>\n"
    end
    menus
  end

  # Método recursivo para gerar submenus e os controles
  def print_menu_entry(sons, entry, view_ctrl, indent=0)
    indent_space = " " * indent
    indent += 2
    submenu = (not sons[entry.id].nil?) ? "class='sub'" : nil

    menus ||= ""
    menus += "\n" + indent_space + "<li #{submenu}>" + link_to("#{entry.menu.title}", entry.menu.page_id ? site_page_path(@site, "#{entry.menu.page_id}") :"#{entry.menu.link}")
    if view_ctrl == 1
      # Se existir um position nulo ele será organizado e todos do seu nível
      if entry.position.nil? or entry.position.to_i < 1 or entry.position.to_i > 2000
        sons[entry.parent_id].each_with_index do |item, idx|
          #menus += " (item.id:#{item.id} entry.id:#{entry.id} idx:#{idx+1}) "
          if item.id == entry.id
            entry.update_attribute(:position, idx+1)
            entry.position = idx+1
          end
        end
      end
      #menus += " [ id:#{entry.id} pos:#{entry.position} ]" # Para debug
      menus += (entry.menu and not entry.menu.link.nil?) ? " [ #{entry.menu.link} ] " : " [ #{entry.menu.page.id if entry.menu.page} ] "
      menus += indent_space + link_to(image_tag('editar.gif', :border => 0, :alt => t("edit")), edit_site_menu_path(@site.name, entry.menu_id), :title => t("edit"))
      menus += indent_space + link_to(image_tag('subitem.gif', :border => 0, :alt => t("add_sub_menu")), new_site_menu_path(@site.name, :parent_id => entry.id), :title => t("add_sub_menu"))
      menus += indent_space + link_to(image_tag('setaup.gif', :border => 0, :alt => t("move_menu_up")), change_position_site_menus_path(:id => entry.id, :position => (entry.position.to_i - 1)), :title => t("move_menu_up")) if entry.position.to_i > 1
      menus += indent_space + link_to(image_tag('setadown.gif', :border => 0, :alt => t("move_menu_down")), change_position_site_menus_path(:id => entry.id, :position => (entry.position.to_i + 1)), :title => t("move_menu_down")) if (entry.position.to_i < sons[entry.parent_id].count.to_i)
      menus += indent_space + link_to(image_tag('apagar.gif', :border => 0, :alt => t("destroy")), rm_menu_site_menus_path(:id => entry.id), :confirm => t('are_you_sure'), :title => t("destroy"))
    end
    menus += "\n" + indent_space + " <menu>" unless submenu.nil?
    if sons[entry.id].class.to_s == "Array"
      sons[entry.id].each do |child|
        menus += print_menu_entry(sons, child, view_ctrl, indent+1)
      end
    end
    menus += "\n" + indent_space + " </menu>" unless submenu.nil?
    menus += "\n" + indent_space + "</li>" unless submenu.nil?
    menus += "</li>" if submenu.nil?
    menus
  end

  # Define mensagens personalizadas
  def flash_message
    messages = ""
    [:notice, :info, :warning, :error].each do |type|
      if flash[type]
        messages += "<div class=\"flash #{type}\">#{flash.now[type]}</div>"
      end
    end
    messages
  end

  # Verifica se o usuário tem permissão no controlador e na ação passada como parâmetro
  # Parâmetros: (Objeto) ctrl, (array) actions
  # Retorna: verdadeiro ou falso
  def check_permission(ctrl, actions)
    # Se o usuário for admin então dê todas as permissões
    if current_user and current_user.is_admin
      return true
    elsif current_user and @site
      # Obtem todos os papéis do usuário relacionados com site
      current_user.roles.where(:site_id => @site).each do |role|
        # Obtem qualquer papél do usuário
        #current_user.roles.each do |role| 
        # Obtem o campo multi-valorados contendo todos os direitos
        role.rights.each do |right|
          # Controlador do usuario (right.controller) = nome do controlador recebido como parâmetro (ctr.controller_name)
          if right.controller == ctrl.controller_name
            # Cria o vetor ri com todos os direitos do usuário
            right.action.split(' ').each do |ri|
              actions.each do |action|
                # Verifica:
                # 1. Se a ação existe no controlador (Caso o usuário tenha adicionado nome incorreto)
                # 2. Direito do usuário (ri) = ação recebida como parâmetro (action)
                if ctrl.instance_methods(false).include?(action.to_sym) and ri.to_s == action.to_s
                  return true
                end
              end
            end
          end
        end
      end
      return false
    end
  end

  # Verifica as permissões do usuário dado um controlador
  # Parametros: (objeto) usuário, (string) controlador
  # Retorna: um vetor com as permissões
  def get_permissions(user, ctr, args={}) # FIXME except no make_menu não está funcionando
    user ||= current_user
    # Se não está logado não existe permissões
    return [args[:except]] if user.nil?
    perms = []
    perms_user = []
    ctr = ctr.empty? ? controller.controller_name : ctr
    if user.is_admin
      return controller.class.instance_methods(false)
    else
      user.roles.where(:site_id => @site).each do |role|
        role.rights.each do |right|
          if right.controller == ctr
            right.action.split(' ').each{ |ri| perms_user << ri }
          end
        end
      end
    end
    if args.length > 0
      if args[:except]
        perms = (controller.class.instance_methods(false) - args[:except]) & perms_user
      elsif args[:only]
        perms = args[:only] & perms_user
      end
      return perms
    end
    return perms_user
  end

  # Monta o menu baseado nas permissões do usuário
  # Parametros: objeto
  def make_menu(obj, args={})
    menu ||= ""
    get_permissions(current_user, '', args).each do |permission|
      if permission and controller.class.instance_methods(false).include?(permission.to_sym)
        case permission.to_s
        when "show"
          menu += link_to(t('show'), {:controller => "#{controller.controller_name}", :action => 'show', :id => obj.id}, :class => 'icon icon-show', :alt => t('show'), :title => t('show')) + " "
        when "edit"
          menu += link_to(t("edit"), {:controller => "#{controller.controller_name}", :action => "edit", :id => obj.id}, :class => 'icon icon-edit', :alt => t('edit'), :title => t('edit')) + " "
        when "destroy"
          menu += link_to((t"destroy"), {:controller => "#{controller.controller_name}", :action => "destroy", :id => obj.id}, :class => 'icon icon-del', :confirm => t('are_you_sure'), :method => :delete, :alt => t('destroy'), :title => t('destroy')) + " "
        end
      end
    end
    menu
  end

  def menu_admin(site=nil)
    adminnav = "<nav id=\"admin\">\n\t"
    adminnav += link_to( t("portal"), root_path )
    adminnav += " | \n\t"

    if site
      adminnav += link_to( t("home"), site )
      adminnav += " | \n\t"
      adminnav += link_to( t("admin.one"), site_admin_index_path(site) )
      adminnav += " | \n\t"
    else
      adminnav += link_to( t("admin.one"), admin_index_path(:back_url => "#{request.fullpath}") )
      adminnav += " | \n\t"
    end

    unless current_user
      adminnav += link_to( t("register"), new_user_path )
      adminnav += " | \n\t"
      adminnav += link_to( t("login"), login_path(:back_url => "#{request.fullpath}"))
      adminnav += " | \n\t"
    else
      adminnav += site ? link_to(t("my_profile"), site_user_path(site, current_user)) : link_to(t("my_profile"), user_path(current_user))
      adminnav += " | \n\t"
      adminnav += link_to( t("logout"), logout_path, :confirm => t("are_you_sure") )
      adminnav += "\n\t"
    end
    # FIXME Contador de usuários não está funcionando ao realizar logoff.
    adminnav += User.logged_in.count.to_s + ' ' + t('user', :count => User.logged_in.count) + ' ' + t('logged') + ".\n"
    adminnav += "</nav>"
    adminnav
  end

  def institutional_bar
    bar = '
    <div class="barra_governo">
      <div class="barra_governo_box">
        <div class="box2">
          <div class="box3">
            <div class="box4">
              <div class="marca_mec">
                <a href="http://portal.mec.gov.br" target="_blank" title="Minist&eacute;rio da Educa&ccedil;&atilde;o">MEC - Minist&eacute;rio da Educa&ccedil;&atilde;o</a>
              </div>
              <div class="marca_brasil">
                <a href="http://www.brasil.gov.br/" target="_blank" title="Portal Brasil">Portal Brasil</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="barra_ufg">
      <div class="barra_ufg_box">
        <a href="http://www.ufg.br"><img src="/images/ufg.png" border="0" alt="UFG" />Universidade Federal de Goiás</a>
        <select onchange="if(options[selectedIndex].value) window.location.href= (options[selectedIndex].value)">
          <option value="" selected="selected">Portal UFG</option>
          <option value="http://sistemas.ufg.br/PORTAL/arquivos/login.php">Portal UFGNet</option>
          <option value="http://www.ufg.br/page.php?menu_id=180&amp;pos=esq">Pró-reitorias</option>
          <option value="http://www.ufg.br/page.php?menu_id=277&amp;pos=esq">Unidades Acadêmicas</option>
          <option value="http://www.prodirh.ufg.br/">Concursos</option>
          <option value="http://www.vestibular.ufg.br/ps2009-2/home.htm">Vestibular</option>
          <option value="http://www.ufg.br/page.php?tipo=fale_conosco_form">Fale Conosco</option>
          <option value="http://www.ufg.br/page.php?menu_id=282&amp;pos=esq">Dúvidas frequentes</option>
        </select>
        <div style="clear: both;"></div>
       </div>
    </div>'
    bar
  end

  def menu_acessibility
    if session[:contrast] == 'yes'
      menu_a = link_to image_tag("alto-contraste2.png", :title => t("high_contrast"), :alt => t("high_contrast")), :contrast => 'no'
      menu_a += "\n"
      menu_a += image_tag("font_size_down_contraste.png", :onclick => "font_size_down()", :alt => t("font_size_down"), :title => t("font_size_down"))
      menu_a += "\n"
      menu_a += image_tag("font_size_original_contraste.png", :onclick => "font_size_original()", :alt => t("font_size_normal"), :title => t("font_size_normal"))
      menu_a += "\n"
      menu_a += image_tag("font_size_up_contraste.png", :onclick => "font_size_up()", :alt => t("font_size_up"), :title => t("font_size_up"))
    else
      menu_a = link_to image_tag("alto-contraste2.png", :title => t("high_contrast"), :alt => t("high_contrast")), :contrast => 'yes'
      menu_a += "\n"
      menu_a += image_tag("font_size_down.png", :onclick => "font_size_down()", :alt => t("font_size_down"), :title => t("font_size_down"))
      menu_a += "\n"
      menu_a += image_tag("font_size_original.png", :onclick => "font_size_original()", :alt => t("font_size_normal"), :title => t("font_size_normal"))
      menu_a += "\n"
      menu_a += image_tag("font_size_up.png", :onclick => "font_size_up()", :alt => t("font_size_up"), :title => t("font_size_up"))
    end
    menu_a
  end

  def menu_locale
    menu_l = link_to image_tag("flags/24/United Kingdom(Great Britain).png", :alt => t("english"), :title => t("english")), :locale => "en"
    menu_l += "\n"
    menu_l += link_to image_tag("flags/24/Brazil.png",  :alt => t("portuguese"), :title => t("portuguese")), :locale => "pt-BR"
    menu_l
  end

  # Método para ordenar tabelas pela coluna
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, params.merge({:sort => column, :direction => direction}), {:class => css_class}
  end

  # Informações sobre paginação
  def info_page(collection)
    if collection.page(1).count > 0
      html = "#{t('views.pagination.displaying')} #{collection.offset_value + 1} - 
      #{collection.offset_value + collection.length}"
      html << " #{t('of')} #{collection.page(1).count} #{t('views.pagination.total')}" 

      content_tag :div, html, :class => "page_info_paginator"
    end
  end

  # Links para selecionar a quantidade de itens por página
  def per_page_links(collection, remote = false)
    if collection.page(1).count > per_page_array.first.to_i
      html = "#{t('views.pagination.per_page')} "

      params[:per_page] = per_page_default if params[:per_page].blank?

      per_page_array.each do |item|
        html << 
        if params[:per_page].to_i == item.to_i
          content_tag :span, item, :class => 'current'
        else
          content_tag(:span, :class => 'item_per_page_paginator') do
            link_to item, params.merge({:per_page => item, :page => 1}), :remote => remote
          end
        end
      end

      content_tag :div, raw(html),
        :class => "per_page_paginator"
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
    if @site and not(@site.per_page_default.blank?)
      @site.per_page_default.to_i
    else
      Site.columns_hash['per_page_default'].default.to_i
    end
  rescue
    if Setting.get(:per_page_default)
      Setting.get(:per_page_default).to_i
    else
      25
    end
  end

  # Pega string de itens por página
  # Ordem: Site, Valor Padrão da coluna, valor fixo.
  def per_page_string
    if @site.per_page.blank?
      Site.columns_hash['per_page'].default
    else
      "#{@site.per_page},#{per_page_default}"
    end
  rescue
    if Setting.get(:per_page)
      "#{Setting.get(:per_page)},#{per_page_default}"
    else
      "5,15,30,60,100,#{per_page_default}"
    end
  end


  # Define qual imagem de exibição será mostrada para o arquivo.
  # Recebe um objeto do tipo Repository
  def archive_type_image(repository)
    unless repository.archive_content_type.include?("image")
      if repository.archive_content_type.include?("pdf") 
        image_t = link_to (image_tag "/images/pdf_file.png", :alt => repository.description, :size => "80x80"), repository.archive.url, :title => repository.description 
      else
        image_t = link_to (image_tag "/images/arquivo.gif", :alt => repository.description, :size => "80x80"), repository.archive.url, :title => repository.description 
      end
    else
      image_t = link_to (image_tag repository.archive.url(:little), :alt => repository.description), repository.archive.url, :title => repository.description 
    end

    image_t
  end

  def load_component component_name
    component = Component.find_by_name(component_name)
    if component
      render :inline => component.body
    else
      # TODO locales
      raw "<h3>Component <i>#{component_name}</i> não encontrado no sistema!</h3>"
    end
  end
end


