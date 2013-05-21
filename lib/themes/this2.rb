class Themes::This2
  attr_reader :menu, :components, :site

  def initialize(site)
    @site = site
    @menu = {}
  end

  def populate
    menus
    components
  end

  def menus
    if @menu.empty?
      @menu['top'] = @site.menus.create({:name => 'Menu Superior'})
      @menu['left'] = @site.menus.create({:name => 'Menu Esquerdo'})
      @menu['right'] = @site.menus.create({:name => 'Menu Direito'})
      @menu['bottom'] = @site.menus.create({:name => 'Menu Inferior'})
    end
  end

  def components
    default_footer = {}
    @site.locales.each do |locale|
      I18n.with_locale(locale.name) do
        default_footer[locale.name] = I18n.t("admin.sites.form.footer_text")
      end
    end

    f = Rails.root.join('lib/themes/this2/components.yml').to_s
    YAML.load_file(f).each do |component|
      # interpolation string on yaml using I18n interpolation
      # https://github.com/svenfuchs/i18n/blob/master/lib/i18n/interpolate/ruby.rb
      component['settings'] = I18n.interpolate(component['settings'], opts(@menu, default_footer))
      @site.components.create(component)
    end
  end

  def opts(menu, default_footer)
    opts = { menu_right_id: menu['right'].id,
             menu_left_id: menu['left'].id,
             menu_top_id: menu['top'].id,
             menu_bottom_id: menu['bottom'].id,
             default_footer: default_footer.to_s }
  end
end
