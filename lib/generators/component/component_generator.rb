# encoding: UTF-8
class ComponentGenerator < Rails::Generators::Base
  desc "Gerador de componentes do Weby\nEx.: rails generate component teste nome:string size:integer"
  source_root File.expand_path('../templates', __FILE__)
  argument :component_name, type: :string, required: true, desc: 'Nome do componente. Ex.: news_list'
  argument :settings, type: :hash, required: false, desc: 'Configurações do componente. Ex.: quant:integer show:boolean text:string '

  def generate_component
    directory('.', "lib/weby/components/#{comp_name}/")
  end

  def comp_name
    component_name.underscore
  end

  def settings_names
    'component_settings ' << settings.map do |name, _type|
      ":#{name}"
    end.join(', ') if settings && settings.any?
  end

  def settings_names_show_view
    ' ' << settings.map do |name, _type|
      "<%= component.#{name} %>\n"
    end.join if settings && settings.any?
  end

  def settings_inputs
    settings.map do |name, type|
      "<%= f.input :#{name}, as: :#{type} %>"
    end.join("\n") if settings && settings.any?
  end

  def settings_locales
    settings.map do |name, _type|
      "        #{name}: \"#{name.titleize}\""
    end.join("\n") if settings && settings.any?
  end
end
