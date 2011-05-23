module SiteComponentsHelper
  # FIXME melhorar a forma de representar os hash e array de configurações
  # Ver o uso de arquivos .yml

  def places_holder
    places = {
      'weby' => ['left', 'right', 'top', 'bottom', 'home', 'first_place'],
      'this2' => ['left', 'right', 'top', 'bottom', 'home', 'first_place']
    }

    places[@site.theme] || []
  end

  def components
    ['banner_horizontal', 'banner_side', 'menu_side', 'feedback', 'info_footer', 'header', 'accessibility_menu', 'front_news', 'no_front_news', 'institutional_bar']
  end

  def components_settings
    {
      'banner_horizontal' => ['category'],
      'banner_side' => ['category'],
      'menu_side' => ['category'],
      'front_news' => ['quant'],
      'no_front_news' => ['quant']
    }
  end
end
