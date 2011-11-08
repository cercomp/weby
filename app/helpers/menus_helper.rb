module MenusHelper

  def set_params_type_value
    if @menu.try(:link) || @menu.link.try('empty?') 
      params[:type] = "internal"
    else 
      params[:type] = "external" 
    end 
  end

  def link_to_menu_type(type)
    link_to t(type.to_s),
      new_site_menu_path(@site, :type => type.to_s),
      update: "div_link",
      remote: true
  end

  def links_to_menu_type(type = "internal")
    links_hash = {
      'internal' => "<span>#{t 'internal' }</span> #{ link_to_menu_type :external }",
      'external' => "#{ link_to_menu_type :internal } <span>#{t 'external' }</span>"
    }

    raw links_hash[type]
  end

end
