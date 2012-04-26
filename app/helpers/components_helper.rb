module ComponentsHelper
  # FIXME melhorar a forma de representar os hash e array de configurações
  # Ver o uso de arquivos .yml

  #TODO - Documentar
  #
  def places_holder
    places = {
      'weby' => ['first_place', 'top', 'left', 'right', 'home', 'bottom'],
      'this2' => ['first_place', 'top', 'left', 'home', 'right', 'bottom'],
      'teacher' => ['first_place', 'top', 'left', 'home', 'bottom'],
      'weby_doc' => ['first_place','home','bottom']
    }

    places[@site.theme] || []
  end

  #retorna as divs do mini layout ---  menu de adicionar componente
  def make_mini_layout
    divs = "<div id='mini_layout'>"  
    places_holder.map do |position|
      divs += "<div id='mini_#{position}' class='hover'> #{t("components.pos.#{position}")}  </div>"
    end
    divs += "</div>" 
  end

  # Busca os componentes existentes no sistema de forma ordenada pelo i18n
  def available_components_sorted
    components = Weby::Components.available_components.map do |c|
      c = Object::const_get(c)
      {name: c.cname, i18n: t("components.#{c.cname}.name")}
    end
    components.sort! {|a,b| a[:i18n] <=> b[:i18n]}
  end
end
