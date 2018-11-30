module MenusHelper
  def acessibility_color_links(component)
    ''.tap do |html|
      if !component.label_contrast.blank?
        html << component.label_contrast
      end
      html << link_to("C", "#", class: "contrast_normal")
      html << link_to("C", "#", class: "contrast_blue", data: { url: asset_path('shared/contrast_blue.css') })
      html << link_to("C", "#", class: "contrast_black", data: { url: asset_path('shared/contrast_black.css') })
      html << link_to("C", "#", class: "contrast_yellow", data: { url: asset_path('shared/contrast_yellow.css') })
    end.html_safe
  end

  def acessibility_font_links(component)
    ''.tap do |html|
      if component.font_size?
        html << "<span class='accessibility_font'>"
        if !component.label_font_size.blank?
          html << component.label_font_size
        end
        html << link_to(weby_icon('plus'), "#", onclick: 'font_size_change("plus")', title: t(".increase_font_size"))
        html << link_to(weby_icon('font'), "#", onclick: 'font_size_original()', title: t(".default_font_size"))
        html << link_to(weby_icon('minus'), "#", onclick: 'font_size_change("minus")', title: t(".decrease_font_size"))
        html << "</span>"
      end
    end.html_safe
  end
end