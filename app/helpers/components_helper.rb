module ComponentsHelper
  #retorna as divs do mini layout ---  menu de adicionar componente
  def make_mini_layout
    content_for :stylesheets, stylesheet_link_tag("mini_layout")
    config = Weby::Themes.layout current_site.theme
    divs = "<div id='mini_layout' style='width: #{config["width"] || 500}px'>"  

    config["placeholders"].map do |placeholders|
      divs += "<div class='mini_level' style='height:#{placeholders["height"] || 25}px'>"
      divs += make_placeholders_divs(placeholders, config["width"] || 500)
      divs += "</div>"
    end

    divs += "</div>" 
  end

  def list_component(compo, leftout=false)
    exceptions = ["show"]
    exceptions << "edit" unless component_is_available(compo.name)
    components_html = "<li "
    components_html << "id='sort_sites_component_#{compo.id }' " unless leftout
    components_html << "class='component component-#{ compo.name } #{'disabled' unless component_is_available(compo.name)} #{compo.publish ? "" : "deactivated"}' data-place='#{compo.place_holder}'>
      <div>
        <span class='widget-name'>
          #{ raw ("#{toggle_field(compo, "publish")} #{t("components.#{compo.name}.name")} - #{compo.alias || compo.default_alias}") }
        </span>
        <div class='pull-right'>
          #{ raw ("#{make_menu(compo, :except => exceptions, :with_text => leftout)}") }
          #{ "<span class='handle'>#{icon('move') }</span>" if check_permission(Sites::Admin::ComponentsController, 'sort') and !leftout }
          #{ link_to "+", new_site_admin_component_path(placeholder: compo.id), class: "btn btn-success btn-sm", title: t(".new_component") if compo.name.to_s == "components_group" and check_permission(Sites::Admin::ComponentsController, [:new]) and !leftout }
        </div>
        <div class='clearfix'></div>
      </div>"
    if compo.name.to_s == "components_group"
      components_per_group = @components.select{|comp| comp.place_holder.to_i == compo.id}
      @components = @components - components_per_group
      components_html << "<div><ul class=\"order-list\" data-place=\"#{compo.id}\">"
      components_per_group.each do |comp|
        component = Weby::Components.factory(comp)
        components_html << list_component(component, leftout)
      end
      components_html << "</ul></div>"
    end
    components_html << "</li>"
    return components_html.html_safe
  end

  # Busca os componentes existentes no sistema de forma ordenada pelo i18n
  def available_components_sorted
    options = {"Weby" => components_as_options(Weby::Components.components(:weby))}

    current_site.extensions.each do |extension|
      extension_components = components_as_options(Weby::Components.components(extension.name.to_sym))
      options[t("extensions.#{extension.name}.name")] = extension_components if extension_components.any?
    end
    
    options
  end

  private
  def components_as_options components
    components.map{|comp, opt| [t("components.#{comp.to_s}.name").strip, comp.to_s] }.sort!{|a,b| a[0] <=> b[0]}
  end

  def make_placeholders_divs(placeholders,width)
    divs = ""
    placeholders["names"].map do |name|
      divs += "<div 
                  id='mini_#{name}'
                  class='hover' 
                  style='width:#{ if placeholders["widths"].nil?
                                    ((width/placeholders["names"].size).to_s + "px") 
                                  else 
                                    (placeholders["widths"][placeholders["names"].index(name)].to_s + "%")
                                  end }; 
                   height:#{placeholders["height"] || 25}px;'>
               #{t("themes.#{current_site.theme}.placeholders.#{name}")}  </div>"
    end
    return divs
  end

end
