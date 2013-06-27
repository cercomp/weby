module ComponentsHelper
  #retorna as divs do mini layout ---  menu de adicionar componente
  def make_mini_layout
    content_for :stylesheets, stylesheet_link_tag("layouts/shared/mini_layout")
    config = Weby::Themes.layout current_site.theme
    divs = "<div id='mini_layout' style='width: #{config["width"] || 500}px'>"  
    
    config["placeholders"].map do |placeholders|
      divs += "<div class='mini_level' style='height:#{placeholders["height"] || 25}px'>"
      divs += make_placeholders_divs(placeholders, config["width"] || 500)
      divs += "</div>"
    end

    divs += "</div>" 
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
    components.map{|comp, opt| [t("components.#{comp.to_s}.name"), comp.to_s] }.sort!{|a,b| a[0] <=> b[0]}
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
               #{t("components.pos.#{name}")}  </div>"
    end
    return divs
  end

end
