module SiteComponentsHelper
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

  #retorna as divs do mini layout
  def make_mini_layout
     divs = "<div id='mini_layout'>"  
     places_holder.map { |position| divs += "<div id='mini_#{position}' class='hover'>
                                            #{t("components.pos.#{position}")}  </div>"} 
     divs += "</div>" 
  end

  #TODO -> Documentar
  #
  def components
    ['banner_horizontal',
     'banner_side',
     'menu_side',
     'feedback',
     'info_footer',
     'header',
     'menu_accessibility',
     'front_news',
     'no_front_news',
     'institutional_bar',
     'weby_bar',
     'news_as_home',
     'gov_bar']
  end

  def components_settings
    {
      'banner_horizontal' => ['category'],
      'no_front_news'     => ['quant', 'front'],
      'banner_side'       => ['category'],
      'front_news'        => ['quant'],
      'menu_side'         => ['category'],
      'news_as_home'      => ['page'],
      'gov_bar'           => ['background']
    }
  end
  
  #TODO -> Documentar
  #
  def components_settings_custom_field
    cur_setting = eval(@site_component.settings);
    {
      'banner_horizontal' => {
        'category' => ['<select name="category">', options_for_select(@site.banners.category_counts.map{|b| b.name}, cur_setting[:category]), '</select>'].join
      },
      
      'banner_side' => {
        'category' => ['<select name="category">', options_for_select(@site.banners.category_counts.map{|b| b.name}, cur_setting[:category]), '</select>'].join
      },
      
      'menu_side' => {
        'category' => ['<select name="category">', options_for_select(@site.menu_categories, cur_setting[:category]), '</select>'].join
      },
      
      'no_front_news' => {
        'front' => '<input type="checkbox" name="front" value="true" />'
      },
      
      'news_as_home' => {
        'page' => ['<a onclick="select_page(); return false;">', t('select_param', :param => t('news.one')), '</a>'].join
      },
      'gov_bar' => {
        'background' => ['<select name="background">', options_for_select([["Azul","#004b82"],["Verde","#00500f"],["Cinza","#7f7f7f"],["Preto","#000000"]], cur_setting[:background]), '</select>'].join
      }
    }
  end
  
  #TODO -> Documentar o que o método faz
  #
  def components_settings_locales
    locales = {}
    self.components_settings.each do |component, array|
      locales[component] = []
      array.each do |v|
        locales[component] << t("components." + v);
      end
    end
    locales
  end
  
  #Método que retorna a categoria que um dados componente está relacionado
  def components_settings_category(site_component)
    if site_component.settings and site_component.settings.include? "category" 
      ini = site_component.settings.index('"')  
      fim = site_component.settings.rindex('"')  
      site_component.settings[ini+1..fim-1] 
    end 
  end
end
