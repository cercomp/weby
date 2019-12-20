class BannerListComponent < Component
  component_settings :category, :orientation, :timer, :show_title, :show_description,
                     :show_controls, :html_class

  validates :category, presence: true
  validates :html_class, format: { with: /\A[A-Za-z0-9_\-]*\z/ }

  def get_banners site
    site.banner_sites
      .includes(:banner)
      .preload(banner: [:repository, :target])
      .published
      .available
      .order("sticker_banner_sites.position DESC, sticker_banner_sites.created_at DESC")
      .tagged_with(category.to_s.mb_chars.downcase.to_s, any: true)
  end

  alias_method :_timer, :timer
  def timer
    _timer.blank? ? '4' : _timer
  end

  def show_controls?
    show_controls.blank? ? false : show_controls == '1'
  end

  def show_title?
    show_title.blank? ? false :  show_title == '1'
  end

  def show_description?
    show_description.blank? ? false :  show_description == '1'
  end

  def show_descriptionarea?
    descriptionarea.blank? ? false :  descriptionarea == '1'
  end

  def default_alias
    category
  end
end
