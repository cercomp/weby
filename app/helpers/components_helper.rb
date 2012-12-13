module ComponentsHelper

  #returns the configuration of an specific layout
  def places_holder
    LAYOUTS[@site.theme] || []
  end

  #retorna as divs do mini layout ---  menu de adicionar componente
  def make_mini_layout
    content_for :stylesheets, stylesheet_link_tag("layouts/shared/mini_layout")
    divs = "<div id='mini_layout'>"  
    
    places_holder.map do |level|
      divs += "<div class='mini_level' style='height:#{level["height"] || 25}px'>"
      divs += make_placeholders_divs(level)
      divs += "</div>"
    end

    divs += "</div>" 
  end

  # Busca os componentes existentes no sistema de forma ordenada pelo i18n
  def available_components_sorted
    components = Weby::Components.components.map do |comp,config|
      c = Object::const_get("#{comp.to_s}_component".classify)
      {name: c.cname, i18n: t("components.#{c.cname}.name")} if config[:enabled]
    end.compact
    components.sort! {|a,b| a[:i18n] <=> b[:i18n]}
  end

  private

  def make_placeholders_divs(level)
    divs = ""
    level["placeholders"].map do |position|
      divs += "<div id='mini_#{position}' class='hover' 
              style='width:#{500/level["placeholders"].size}px; height:#{level["height"] || 25}px' >
              #{t("components.pos.#{position}")}  </div>"
    end
    return divs
  end

end
