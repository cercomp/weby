class Weby::Theme
  attr_reader :name, :title, :components, :extensions, :variables, :layout, :template

  def initialize(name)
    @name = name
    @extensions = YAML.load_file Rails.root.join("lib/weby/themes/#{@name}/extensions.yml")
    @components = YAML.load_file Rails.root.join("lib/weby/themes/#{@name}/components.yml")
    @layout = YAML.load_file Rails.root.join("lib/weby/themes/#{@name}/layout.yml")
    @template = "lib/weby/themes/#{@name}/layouts/#{@name}.html.erb"
    @title = @layout['title'] || @name.titleize
  end

  def populate skin, opts
    @skin = skin
    @user = opts[:user]
    populate_extensions if @extensions
    populate_components if @components
  end

  private

  def create_component place, component
    component = component.dup
    component['place_holder'] = place
    if component['name'] == 'menu'
      menu_attrs = component.delete('menu') || {}
      target_menu = @skin.site.menus.find_by(name: menu_attrs['name']) || @skin.site.menus.create(menu_attrs)
      component['settings'] = I18n.interpolate(component['settings'], menu_id: target_menu.id)
      #menu items
      if target_menu.root_menu_items.empty? && menu_attrs['items'].present?
        menu_attrs['items'].each do |item|
          locale = @skin.site.locales.order(:id).first
          target_menu.menu_items.create(i18ns_attributes: [{locale_id: (locale.try(:id) || 1), title: item['title']}], url: item['url'], position: item['position'])
        end
      end
    end
    if component['name'] == 'text'
      component['settings'] = I18n.interpolate(component['settings'], default_footer: @default_footer.to_s)
    end
    if component['name'] == 'components_group'
      children = component.delete('children')
    end
    if component['name'] == 'news_as_home'
      page_attrs = component.delete('page') || {}
      if page_attrs.present?
        locale = @skin.site.locales.order(:id).first
        page = @skin.site.pages.create(i18ns_attributes: [{locale_id: (locale.try(:id) || 1), title: page_attrs['title'], text: page_attrs['text']}], publish: true, user: @user)
        component['settings'] = I18n.interpolate(component['settings'], page_id: page.id)
      end
    end

    compo = @skin.components.create(component)
    if children && children.any? && compo.persisted?
      children.each do |child|
        create_component compo.id, child
      end
    end
  end

  def populate_components
    return if @skin.components.any? #@site.active_skin.components.where(theme: @name).destroy_all

    @default_footer = {}
    @skin.site.locales.each do |locale|
      I18n.with_locale(locale.name) do
        @default_footer[locale.name] = I18n.t('admin.sites.form.footer_text')
      end
    end

    @components.each do |place, comps|
      comps.each do |component|
        component = component.dup
        #component['theme'] = @name
        create_component place, component
      end
    end
  end

  def populate_extensions
    @extensions.each do |extension|
      @skin.site.extensions.create(extension)
    end
  end

end
