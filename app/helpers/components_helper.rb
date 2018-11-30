module ComponentsHelper
  # returns the mini layout  divs ---  The menu that attaches an component to a block
  def make_mini_layout
    theme = @skin.base_theme
    width = theme.layout['width'] || 500

    content_for :stylesheets, stylesheet_link_tag('mini_layout')
    divs = "<div id='mini_layout' style='width: #{width}px'>"

    theme.layout['placeholders'].map do |placeholders|
      divs += "<div class='mini_level' style='height:#{placeholders['height'] || 25}px'>"
      divs += make_placeholders_divs(theme, placeholders, width)
      divs += '</div>'
    end

    divs += '</div>'
  end

  def list_component(compo, leftout = false)
    exceptions = ['show']
    exceptions << 'edit' unless component_is_available(compo.name)
    components_html = '<li '
    components_html << "id='sort_sites_component_#{compo.id }' " unless leftout
    nickname = compo.alias.present? ? compo.alias : compo.default_alias
    if compo.name.to_s == 'components_group'
      components_html << "class='component-#{ compo.name } "
    else
      components_html << "class='component "
    end
    components_html << "#{'disabled' unless component_is_available(compo.name)} #{compo.publish ? '' : 'deactivated'}' data-place='#{compo.place_holder}'>
      <div>
        <span class='widget-name'>
          #{ raw ("#{toggle_field(compo, 'publish', 'toggle', controller: :components, skin_id: compo.skin_id)} #{t("components.#{compo.name}.name")} #{"- #{nickname}" if nickname.present?}") }
        </span>
        <div class='pull-right' style='min-width: 46px'>
          #{ raw ("#{make_menu(compo, except: exceptions, with_text: leftout, controller: Sites::Admin::ComponentsController, params: {skin_id: compo.skin_id})}") }
          #{ "<span class='handle'>#{icon('move') }</span>" if check_permission(Sites::Admin::ComponentsController, 'sort') and !leftout }
          #{ link_to '+', new_site_admin_skin_component_path(compo.skin_id, placeholder: compo.id), class: 'btn btn-success btn-sm', title: t('.new_component') if compo.name.to_s == 'components_group' and check_permission(Sites::Admin::ComponentsController, [:new]) and !leftout }
        </div>
        <div class='clearfix'></div>
      </div>"
    if compo.name.to_s == 'components_group'
      components_per_group = @components.select { |comp| comp.place_holder.to_i == compo.id }
      @components = @components - components_per_group
      components_html << "<div><ul class=\"order-list\" data-place=\"#{compo.id}\">"
      components_per_group.each do |comp|
        component = Weby::Components.factory(comp)
        components_html << list_component(component, leftout)
      end
      components_html << '</ul></div>'
    end
    components_html << '</li>'
    components_html.html_safe
  end

  # Search for the existing components ordering by the I18N name
  def available_components_sorted
    options = { 'Weby' => components_as_options(Weby::Components.components(:weby)) }

    current_site.active_extensions.each do |extension|
      extension_components = components_as_options(Weby::Components.components(extension.name.to_sym))
      options[t("extensions.#{extension.name}.name")] = extension_components if extension_components.any?
    end

    options
  end

  private
  def components_as_options(components)
    components.map { |comp, _opt| [t("components.#{comp}.name").strip, comp.to_s] }.sort! { |a, b| a[0] <=> b[0] }
  end

  # Generate the mini-layout view so  the user can choose the placeholder
  def make_placeholders_divs(theme, placeholders, width)
    divs = ''
    placeholders['names'].map do |name|
      divs += "<div
                  id='mini_#{name}'
                  class='hover'
                  style='width:#{ if placeholders['widths'].nil?
                                    ((width / placeholders['names'].size).to_s + 'px')
                                  else
                                    (placeholders['widths'][placeholders['names'].index(name)].to_s + '%')
                                  end };
                   height:#{placeholders['height'] || 25}px;'>
               #{t("themes.#{theme.name}.placeholders.#{name}")}  </div>"
    end
    divs
  end
end
