module ComponentsHelper
  # FIXME melhorar a forma de representar os hash e array de configurações
  # Ver o uso de arquivos .yml

  #TODO - Documentar
  #
  def places_holder
    places = {
      'weby' => ['first_place', 'top', 'left', 'right', 'home', 'bottom'],
      'this2' => ['first_place', 'top', 'left', 'home', 'right', 'bottom'],
      'weby_doc' => ['first_place', 'top' ,'home','bottom'],
      'interteias' => ['first_place', 'top', 'home', 'bottom']
    }

    places[@site.theme] || []
  end

  #retorna as divs do mini layout ---  menu de adicionar componente
  def make_mini_layout
    content_for :stylesheets, stylesheet_link_tag("layouts/#{current_site.theme}/mini")
    divs = "<div id='mini_layout'>"  
    places_holder.map do |position|
      divs += "<div id='mini_#{position}' class='hover'> #{t("components.pos.#{position}")}  </div>"
    end
    divs += "</div>" 
  end

  # Busca os componentes existentes no sistema de forma ordenada pelo i18n
  def available_components_sorted
    options = {"Weby" => components_as_options(Weby::Components.components(:weby))}

    current_site.extensions.each do |extension|
      options[t("extensions.#{extension.name}.name")] = components_as_options(Weby::Components.components(extension.name.to_sym))
    end
    
    options
  end

  private
  def components_as_options components
    components.map{|comp, opt| [t("components.#{comp.to_s}.name"), comp.to_s] }.sort!{|a,b| a[0] <=> b[0]}
  end
end
