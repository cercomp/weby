module Weby
  module Components
    
    def self.setup
      yield self
    end

    @components = {}

    #O padrão das flags enabled e aliasable é true
    def self.register_component(comp_name, config={})
      config[:enabled] = true if config[:enabled].nil?
      config[:aliasable] = true if config[:aliasable].nil?

      #require "weby/components/#{comp_name.to_s}/#{comp_name.to_s}_component"

      # Adiciona locales do componente no path de locales
      Weby::Application.config.i18n.load_path +=
        Dir[Rails.root.join('lib', 'weby', 'components', comp_name.to_s, 'locales', '*.{rb,yml}').to_s]

      # Adiciona assets do componente no path de assets
      Weby::Application.config.assets.paths +=
        Dir[Rails.root.join('lib', 'weby', 'components', comp_name.to_s, 'assets', '**')]
      @components[comp_name.to_sym] = config
    end

    def self.components
      @components
    end

    def self.component(comp_name)
      @components[comp_name.to_sym]
    end

    def self.is_enabled?(comp_name)
      @components[comp_name.to_sym][:enabled] if @components[comp_name.to_sym]
    end

    def self.is_aliasable?(comp_name)
      @components[comp_name.to_sym][:aliasable] if @components[comp_name.to_sym]
    end

    def self.factory(component)
      # A idéia é pegar um componente definido com a classe "Component" e passar
      # para a classe filha
      if component.class == Component
        build = Object::const_get("#{component.name.classify}Component").instantiate(component.attributes)
      else
        ## FIXME verifica se o componente existe
        build = Object::const_get("#{component.classify}Component").new
      end

      return build
    end
    
    ActionView::Helpers::RenderingHelper.module_eval do

#      def load_components(component_place)
#        raw([].tap do |components|
#          current_site.components.where(["publish = true AND place_holder = ?", component_place]).order('position asc').each do |comp|
#            if Weby::Components.is_enabled?(comp.name)
#              visible = comp.visibility == 1 ? current_page?(site_path) : comp.visibility == 2 ? !current_page?(site_path) : comp.visibility == 0
#              if visible
#                components << render_component(Weby::Components.factory(comp))
#              end
#            end
#          end
#        end.join)
#      end

      #chama 'content_for :layout_<place_holder>', use yield :layout_<place_holder> para mostrar
      def load_components
        @global_components.reject{|k,v| k == :home }.each do |place, comps|
          comps.each do |comp|
            if Weby::Components.is_enabled?(comp.name)
              visible = comp.visibility == 1 ? current_page?(site_path) : comp.visibility == 2 ? !current_page?(site_path) : comp.visibility == 0
              if visible
                content_for "layout_#{place}".to_sym, render_component(Weby::Components.factory(comp))
              end
            end
          end
        end
      end

      def render_home_components
        raw([].tap do |components|
          @global_components[:home].each do |comp|
            if Weby::Components.is_enabled?(comp.name)
              visible = comp.visibility == 1 ? current_page?(site_path) : comp.visibility == 2 ? !current_page?(site_path) : comp.visibility == 0
              if visible
                components << render_component(Weby::Components.factory(comp))
              end
            end
          end if @global_components[:home]
        end.join)
      end

      def render_component(component, view = 'show', args = {})

        args[:partial] = "#{component.name}/views/#{view.to_s}"
        
        args[:locals] ||= {}
        args[:locals].merge!({ :component => component })

        # Caso a partial não exista, não mostra nada
        begin
          if Weby::Application.assets.find_asset("#{component.name}.css")
            @stylesheets_loaded ||= []
            #Incluir o css do componente somente uma vez, mesmo se existirem mais de um sendo exibido
            unless(@stylesheets_loaded.include?(component.name))
              content_for :components_stylesheets, stylesheet_link_tag("#{component.name}")
              @stylesheets_loaded << component.name
            end
          end
          output = render args
          output = output.sub(/(class=\"[a-z_\-]+_component\s?[a-z0-9_\-]*\")/, "\\1 id=\"component_#{component.id}\"")
        rescue ActionView::MissingTemplate
          output = ''
        end
        raw output
      end

      #Inclui somente uma vez, mesmo se chamado várias vezes,
      #por exemplo se o mesmo componente foi incluido mais de uma vez
      def include_component_javascript(content_for, javascript_name)
        if Weby::Application.assets.find_asset(javascript_name)
          @javascripts_loaded ||= []
          #Incluir o js somente uma vez, mesmo se existirem mais de um componente sendo exibido
          unless(@javascripts_loaded.include?(javascript_name))
            content_for content_for, javascript_include_tag(javascript_name)
            @javascripts_loaded << javascript_name
          end
        end
      end
    end

    module Form
      def component_i18n_input(locale, attribute_name, options={}, &block)
        options[:input_html] = (options[:input_html] || {}).merge({
            :value => @object.respond_to?("#{attribute_name}_i18n".to_sym) ? @object.send("#{attribute_name}_i18n".to_sym, locale.name) : "",
            :name => "#{@object_name}[#{attribute_name}][#{locale.name}]",
            :id => "#{@object_name}_#{attribute_name}_#{locale.name}"})

        input attribute_name, options, &block
      end
    end
  end

  SimpleForm::FormBuilder.send(:include, Weby::Components::Form)
  #ActionView::Helpers::FormBuilder.send(:include, Weby::Components::Form)

  module ComponentInstance
    def self.extended(base)
      base.class_eval do
        class << self
          def inherited_with_weby(cbase)
             inherited_without_weby cbase
             cbase.class_eval do
              # Como do componente que será usando em algumas partes do sistema
              # TODO 
              def self.cname
                # Por padrão toda classe componente terá o "Component" no fim do nome, o come do
                # componente não precisa ter esse final
                # ex: GovBarComponent.tableize # => gov_bar_component.gsub(...) => gov_bar
                self.name.tableize.gsub(/_components$/, '')
              end

              # Inicializa o nome do componente quando ele é criado
              after_initialize do
                self.name = self.class.name.tableize.gsub(/_components$/, '')
              end

              default_scope where(:name => self.cname)
             end
          end
          alias_method_chain :inherited, :weby
        end
      end
    end

    def component_settings(*settings)
      settings.each do |setting|
        class_eval <<-METHOD
          @#{setting}
          def #{setting}=(value)
            settings_map[:#{setting}] = value
          end
          
          def #{setting}
            settings_map[:#{setting}]
          end
        METHOD
      end
    end
    #Este método deve ser chamado depois de component_settings, nunca antes
    def i18n_settings(*settings)
      settings.each do |setting|
        raise ArgumentError, "Unknown setting for 'i18n_settings' in #{self.name}: #{setting}. A prior call to 'component_settings' is required" unless self.public_instance_methods.include? setting.to_sym
        class_eval <<-METHOD
          def #{setting}
            val = settings_map[:#{setting}]
            if val.is_a? Hash
              return val[I18n.locale.to_s].present? ?
                val[I18n.locale.to_s] : val[I18n.default_locale.to_s].present? ?
                   val[I18n.default_locale.to_s] : val.values.sort.last
            end
            ""
          end

          def #{setting}_i18n(locale)
            val = settings_map[:#{setting}]
            if val.is_a? Hash
              return val[locale]
            end
            ""
          end
        METHOD
      end
    end
  end
end
