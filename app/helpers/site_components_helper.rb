module SiteComponentsHelper
  # FIXME melhorar a forma de representar os hash e array de configurações
  # Ver o uso de arquivos .yml

  def places_holder
    places = {
      'weby' => ['left', 'right', 'top', 'bottom'],
      'this2' => ['left', 'right', 'top', 'bottom']
    }

    places[@site.theme] || []
  end

  def components
    ['banner_horizontal', 'banner_side', 'menu_side', 'feedback', 'info_footer', 'header', 'accessibility_menu']
  end

  def components_settings
    {
      'banner_horizontal' => ['category'],
      'banner_side' => ['category'],
      'menu_side' => ['category']
    }
  end
end
