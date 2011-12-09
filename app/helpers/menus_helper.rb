module MenusHelper

  def set_params_type_value
    if @menu.try(:link) and not @menu.link.try('empty?') 
      params[:type] = "external" 
    else 
      params[:type] = 'internal'
    end 
  end

  def link_to_menu_type(type, action)
    link_to t(type.to_s), {controller: 'menus', action: action.to_s, type: type.to_s},
      update: "div_link",
      remote: true
  end

  def links_to_menu_type(type = "internal", action)
    links_hash = {
      'internal' => "<span>#{t 'internal'}</span> #{link_to_menu_type(:external, action)}",
      'external' => "#{link_to_menu_type(:internal, action)} <span>#{t 'external'}</span>"
    }

    raw links_hash[type]
  end

end
