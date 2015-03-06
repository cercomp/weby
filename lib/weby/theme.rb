class Weby::Theme
  attr_reader :name, :components, :extensions, :variables, :layout, :template

  def initialize(name)
    @name = name
    @extensions = YAML.load_file Rails.root.join("lib/weby/themes/#{@name}/extensions.yml")
    @components = YAML.load_file Rails.root.join("lib/weby/themes/#{@name}/components.yml")
    @layout = YAML.load_file Rails.root.join("lib/weby/themes/#{@name}/layout.yml")
    @template = "lib/weby/themes/#{@name}/layouts/#{@name}.html.erb"
  end

  def populate site
    @site = site
    populate_extensions if @extensions
    populate_components if @components
  end

  private

  def populate_components
    default_footer = {}
    @site.locales.each do |locale|
      I18n.with_locale(locale.name) do
        default_footer[locale.name] = I18n.t('admin.sites.form.footer_text')
      end
    end

    return if @site.components.where(theme: @name).any? #@site.components.where(theme: @name).destroy_all
    @components.each do |place, comps|
      comps.each do |component|
        component['place_holder'] = place
        component['theme'] = @name
        if component['name'] == 'menu'
          menu = @site.menus.create(component.delete('menu'))
          component['settings'] = I18n.interpolate(component['settings'], menu_id: menu.id)
        end
        if component['name'] == 'text'
          component['settings'] = I18n.interpolate(component['settings'], default_footer: default_footer.to_s)
        end
        @site.components.create(component)
      end
    end
  end

  def populate_extensions
    @extensions.each do |extension|
      @site.extensions.create(extension)
    end
  end
end
