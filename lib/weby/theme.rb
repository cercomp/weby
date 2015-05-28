class Weby::Theme
  attr_reader :name, :components, :extensions, :variables, :layout, :template

  def initialize(name)
    @name = name
    @extensions = YAML.load_file Rails.root.join("lib/weby/themes/#{@name}/extensions.yml")
    @components = YAML.load_file Rails.root.join("lib/weby/themes/#{@name}/components.yml")
    @layout = YAML.load_file Rails.root.join("lib/weby/themes/#{@name}/layout.yml")
    @template = "lib/weby/themes/#{@name}/layouts/#{@name}.html.erb"
  end

  def populate skin
    @skin = skin
    populate_extensions if @extensions
    populate_components if @components
  end

  private

  def populate_components
    default_footer = {}
    @skin.site.locales.each do |locale|
      I18n.with_locale(locale.name) do
        default_footer[locale.name] = I18n.t('admin.sites.form.footer_text')
      end
    end

    return if @skin.components.any? #@site.components.where(theme: @name).destroy_all
    @components.each do |place, comps|
      comps.each do |component|
        component['place_holder'] = place
        #component['theme'] = @name
        if component['name'] == 'menu'
          menu = @skin.site.menus.create(component.delete('menu'))
          component['settings'] = I18n.interpolate(component['settings'], menu_id: menu.id)
        end
        if component['name'] == 'text'
          component['settings'] = I18n.interpolate(component['settings'], default_footer: default_footer.to_s)
        end
        if component['name'] == 'components_group'
          component['children'].each do |child|
            #TODO insert component with component_id as placeholder
          end
        end
        @skin.components.create(component)
      end
    end
  end

  def populate_extensions
    @extensions.each do |extension|
      @skin.site.extensions.create(extension)
    end
  end
end
