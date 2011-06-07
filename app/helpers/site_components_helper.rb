module SiteComponentsHelper
  # FIXME melhorar a forma de representar os hash e array de configurações
  # Ver o uso de arquivos .yml

  def places_holder
    places = {
      'weby' => ['left', 'right', 'top', 'bottom', 'home', 'first_place'],
      'this2' => ['left', 'right', 'top', 'bottom', 'home', 'first_place'],
      'teachers' => ['left', 'top', 'bottom', 'home', 'first_place']
    }

    places[@site.theme] || []
  end

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
     'news_as_home']
  end

  def components_settings
    {
      'banner_horizontal' => ['category'],
      'no_front_news'     => ['quant', 'front'],
      'banner_side'       => ['category'],
      'front_news'        => ['quant'],
      'menu_side'         => ['category'],
      'news_as_home'      => ['page']
    }
  end
  
  def components_settings_custom_field
    cur_setting = eval(@site_component.settings);
    {
      'banner_horizontal' => {
        'category' => ['<select name="category">', options_for_select(@site.banner_categories, cur_setting[:category]), '</select>'].join
      },
      
      'banner_side' => {
        'category' => ['<select name="category">', options_for_select(@site.banner_categories, cur_setting[:category]), '</select>'].join
      },
      
      'menu_side' => {
        'category' => ['<select name="category">', options_for_select(@site.menu_categories, cur_setting[:category]), '</select>'].join
      },
      
      'no_front_news' => {
        'front' => '<input type="checkbox" name="front" value="true" />'
      },
      
      'news_as_home' => {
        'page' => ['<a onclick="select_page(); return false;">', t('select_param', :param => t('news.one')), '</a>'].join
      }
    }
  end
  
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
end
