module SiteComponentsHelper
  # FIXME melhorar a forma de representar os hash e array de configurações
  # Ver o uso de arquivos .yml

  def places_holder
    places = {
      'weby' => ['left', 'right', 'top', 'bottom']
    }

    places[@site.theme] || []
  end

  def components
    ['banner_horizontal', 'banner_side', 'menu_side']
  end

  def components_settings
    {
      'banner_horizontal' => ['id', 'category'],
      'banner_side' => [],
      'menu_side' => ['class', 'category']
    }
  end
end
