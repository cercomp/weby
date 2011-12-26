module CssesHelper
  def make_menu_css(cssrel, args={})
    menu = ''
    ctr = args[:controller].nil? ? controller : CssesController
    get_permissions(current_user, :controller => ctr).each do |permission|
      if controller.class.instance_methods(false).include?(permission.to_sym)
        if @site.id == cssrel.site.id
          case permission.to_s
          when "show"
            menu += link_to(t('show'), [@site, cssrel.css], :class => 'icon icon-show',
                    :alt => t('show'), :title => t('show')) + " "

          when "edit"
            menu += link_to(t("edit"), edit_site_css_path(@site, cssrel.css), :class => 'icon icon-edit',
                    :alt => t('edit'), :title => t('edit')) + " "

          when "destroy"
            # verify if css belongs only to owner
            if cssrel.css.sites.count == 1
              menu += link_to(t("destroy"), site_css_path(@site, cssrel.css), :class => 'icon icon-del',
                      :confirm => t("are_you_sure"), :method => :delete, :alt => t("destroy"), :title => t("destroy")) + " "
            end
          end
        else
          case permission.to_s
          when "show"
            menu += link_to(t('show'), [@site, cssrel.css], :class => 'icon icon-show',
                    :alt => t('show'), :title => t('show')) + " "
          when "copy"
            menu += link_to(t('copy'), copy_site_css_path(@site, cssrel.css), :class => 'icon icon-fav',
                    :alt => t('copy'), :title => t('copy')) + " "
          end
        end
      end
    end
    raw menu
  end

  def follow(obj)
    following = @site == obj.site and obj.owner 
    if following
      menu = link_to(image_tag("true.png", :alt => t("enable.masc")), {:action => "follow", :id => obj.id, :following => "#{following}"}, :title => t("activate_deactivate"))
    else
      menu = link_to(image_tag("false.png", :alt => t("disable.masc")), {:action => "follow", :id => obj.id, :following => "#{following}"}, :title => t("activate_deactivate"))
    end
    raw menu
  end

  def list_css_sites site_css
    max_lenght = 45
    result = (site_css.css.sites - [@site]).map{|s| s.name }.join(", ")
    if result.size > max_lenght
      raw "#{result[0..max_lenght]}<a href=\"#\" class=\"more\"> ...mais</a><span style=\"display:none\">#{result[max_lenght..-1]}</span>"
    else
      raw result
    end
  end
end
