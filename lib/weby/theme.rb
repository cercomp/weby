class Weby::Theme
  attr_reader :components, :extensions, :site

  def initialize(site)
    @site = site
    @extensions_yaml = "lib/weby/themes/#{@site.theme}/extensions.yml"
    @components_yaml = "lib/weby/themes/#{@site.theme}/components.yml"
  end

  def populate
    extensions if File.exists? @extensions_yaml
    components if File.exists? @components_yaml
    Weby::Rights.seed_roles @site.id
  end

  def components
    default_footer = {}
    @site.locales.each do |locale|
      I18n.with_locale(locale.name) do
        default_footer[locale.name] = I18n.t("admin.sites.form.footer_text")
      end
    end

    f = Rails.root.join(@components_yaml).to_s
    YAML.load_file(f).each do |place, comps|
      comps.each do |component|
        component['place_holder'] = place
        if component['name'] == 'menu'
          menu = @site.menus.create(component.delete('menu'))
          component['settings'] = I18n.interpolate(component['settings'], {menu_id: menu.id})
        end
        if component['name'] == 'text'
          component['settings'] = I18n.interpolate(component['settings'], {default_footer: default_footer.to_s})
        end
        @site.components.create(component)
      end
    end
  end

  def extensions
    f = Rails.root.join(@extensions_yaml).to_s
    YAML.load_file(f).each do |extension|
      @site.extensions.create(extension)
    end
  end
end
