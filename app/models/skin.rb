class Skin < ApplicationRecord

  belongs_to :site

  has_many :components, dependent: :destroy
  has_many :root_components, -> { order(:position).where("place_holder !~ '^\\d*$'") }, class_name: 'Component'
  has_many :styles, -> { order('styles.position DESC') }, dependent: :destroy


  def base_theme
    Weby::Themes.theme(theme)
  end

  def layout
    base_theme.layout.merge(attributes[:layout].to_h)
  end

  #def components
  #  base_theme.components.merge(attributes[:components].to_h)
  #end

  def self.import(attrs, options = {})
    return attrs.each { |attr| import attr, options } if attrs.is_a? Array

    attrs = attrs.dup
    attrs = attrs['skin'] if attrs.key? 'skin'

    styles = attrs.delete('styles')
    components = attrs.delete('root_components')

    attrs.except!('id', 'created_at', 'updated_at', 'site_id', '@type', 'type')

    #search if this skin already exist
    skin = self.find_by theme: attrs['theme'], site_id: options[:site_id]
    if skin
      skin.update(attrs)
      #!!
      skin.components.destroy_all
      skin.styles.destroy_all

      newskin = skin
    else
      newskin = self.create!(attrs)
    end

    newskin.styles.import(styles)
    newskin.components.import(components, site_id: options[:site_id])
  end

  def components_yml
    list = root_components.group_by(&:place_holder)
    list = list.map do |place, comps|
      [
        place,
        comps.map.with_index do |comp, idx|
          json = comp.as_json(only: [:name, :alias, :position, :publish, :settings])
          json['position'] = idx+1
          parse_component_hash(json)
        end
      ]
    end.to_h.to_yaml
  end

  def get_variable name
    self.variables = '{}' if self.variables.blank?
    eval(variables)[name]
  end

  def get_variable_config name
    get_all_color_options(name)[get_variable(name)]
  end

  def set_variable name, value
    self.variables = '{}' if self.variables.blank?
    vars = eval(self.variables)
    vars[name] = value
    self.variables = vars.to_s
  end

  def get_custom_colors(variable_name)
    self.variables = '{}' if self.variables.blank?
    vars = eval(variables)
    vars["#{variable_name}_custom"] || {}
  end

  # Adiciona cor customizada na estrutura de custom_colors (persistida em variables)
  def add_custom_color(variable_name, color_value, custom_key = nil)
    self.variables = '{}' if self.variables.blank?
    vars = eval(self.variables)
    vars["#{variable_name}_custom"] ||= {}
    # Gera um id único se não fornecido
    custom_key ||= "#{variable_name}_custom"
    vars["#{variable_name}_custom"][custom_key] = {
      'main' => color_value,
      'sub' => color_value,
      'group' => 'custom'
    }
    self.variables = vars.to_s
    save!
  end

  def remove_custom_color(_variable_name, color_name)
    self.variables = '{}' if self.variables.blank?
    vars = eval(self.variables)
    vars["#{_variable_name}_custom"] ||= {}
    vars["#{_variable_name}_custom"].delete(color_name)
    self.variables = vars.to_s
    save!
  end

  def get_all_color_options(variable_name)
    # Combina cores do tema com cores personalizadas persistidas em variables['custom_colors']
    theme_colors = base_theme.variables[variable_name].to_h.fetch('values', {})
    custom_colors = get_custom_colors(variable_name)
    theme_colors.merge(custom_colors)
  end

  private

  def parse_component_hash json
    json.stringify_keys!
    json.delete('alias') if json['alias'].blank?
    case json['name']
    when 'menu'
      sett = eval(json['settings'])
      sett[:menu_id] = "%{menu_id}"
      json['settings'] = sett.to_s
      json['menu'] = {'name' => 'Principal'}
    when 'subsite_front_news'
      sett = eval(json['settings'])
      sett.delete(:sel_site)
      json['settings'] = sett.to_s
    when 'image'
      sett = eval(json['settings'])
      sett.delete(:repository_id)
      json['settings'] = sett.to_s
    when 'news_as_home'
      json['page'] = {'title' => 'Título', 'text' => 'Texto'}
    end
    if json['children'].blank?
      json.delete('children')
    else
      json['children'] = json['children'].map.with_index do |child, idx|
        parsed = parse_component_hash(child)
        parsed['position'] = idx+1
        parsed
      end
    end
    json
  end

end
