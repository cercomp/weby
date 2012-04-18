module ComponentsHelper
  # FIXME melhorar a forma de representar os hash e array de configurações
  # Ver o uso de arquivos .yml

  #TODO - Documentar
  #
  def places_holder
    places = {
      'weby' => ['left', 'right', 'top', 'bottom', 'home', 'first_place'],
      'this2' => ['first_place', 'top', 'left', 'home', 'right', 'bottom'],
      'teachers' => ['first_place', 'top', 'left', 'home', 'bottom']
    }

    places[@site.theme] || []
  end

  #retorna as divs do mini layout ---  menu de adicionar componente
  def make_mini_layout
     divs = "<div id='mini_layout'>"  
     places_holder.map { |position| divs += "<div id='mini_#{position}' class='hover'>
                                            #{t("components.pos.#{position}")}  </div>"} 
     divs += "</div>" 
  end

  def available_components_sorted
    components = Weby::Components.available_components.map do |c|
      {name: c.component_name, i18n: t("components.#{c.component_name}.name")}
    end
    components.sort! {|a,b| a[:i18n] <=> b[:i18n]}
  end
end
