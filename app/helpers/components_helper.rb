module ComponentsHelper

  #returns the configuration of an specific layout
  def layout_config
    LAYOUTS[@site.theme] || []
  end

  #retorna as divs do mini layout ---  menu de adicionar componente
  def make_mini_layout
    content_for :stylesheets, stylesheet_link_tag("layouts/shared/mini_layout")
    config = layout_config
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
    components = Weby::Components.components.map do |comp,config|
      c = Object::const_get("#{comp.to_s}_component".classify)
      {name: c.cname, i18n: t("components.#{c.cname}.name")} if config[:enabled]
    end.compact
    components.sort! {|a,b| a[:i18n] <=> b[:i18n]}
  end

  private

  def make_placeholders_divs(placeholders,width)
    divs = ""
    placeholders["names"].map do |name|
      divs += "<div id='mini_#{name}' class='hover' 
               style='width:#{width/placeholders["names"].size - 1}px;
               height:#{placeholders["height"] || 25}px' >
               #{t("components.pos.#{name}")}  </div>"
    end
    return divs
  end

end
