module MenusHelper

  def link_to_menu_type(type)
    link_to t(type.to_s),
      new_site_menu_path(@site, :type => type.to_s),
      :update => "div_link",
      :remote => true
  end

  def links_to_menu_type(type)
    links_hash = {
      'internal' => "#{t 'internal' } | #{ link_to_menu_type :external }",
      'external' => "#{ link_to_menu_type :internal } | #{t 'external' }"
    }

    return links_hash[type]
  end

end
