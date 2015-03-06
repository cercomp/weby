class Theme < ActiveRecord::Base

  def base_theme
    Weby::Themes.theme(base)
  end

  def layout
    base_theme.layout.merge(attributes[:layout].to_h)
  end

  def components
    base_theme.components.merge(attributes[:components].to_h)
  end

end
