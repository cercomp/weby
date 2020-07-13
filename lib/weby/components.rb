module Weby
  module Components
    def self.setup
      yield self
    end

    attr_reader :components
    @components = {}

    # O padrão das flags enabled e aliasable é true
    def self.register_component(comp_name, config = {})
      config[:enabled] = true if config[:enabled].nil?
      config[:aliasable] = true if config[:aliasable].nil?

      # identificar se é componente de engine
      match = caller.first.split(':')[0].match(/\/engines\/([^\/]+)\//)
      if match
        config[:group] = match[1].to_sym
      else
        config[:group] = :weby
      end

      @components[comp_name.to_sym] = config
    end

    def self.components(group = nil, include_disabled = false)
      comp = include_disabled ? @components : @components.select { |_comp, opt| opt[:enabled] }
      comp = comp.select { |_comp, opt| opt[:group] == group } if group
      comp
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
        build = Object.const_get("#{component.name.camelize}Component").instantiate(component.attributes)
      else
        ## FIXME verifica se o componente existe
        build = Object.const_get("#{component.camelize}Component").new
      end

      build
    end

    ActionView::Helpers::RenderingHelper.module_eval do

      # executa 'content_for :layout_<place_holder>', use yield :layout_<place_holder> para mostrar
      def load_components
        @global_components.reject { |k, _v| k == :home }.each do |place, comps|
          content_for_components place, comps
        end
      end

      def render_home_components
        content_for_components :home, @global_components[:home]
      end

      def content_for_components(place, comps)
        comps.each do |compo_setting|

          comp = if compo_setting[:component].is_a?(Component)
                   compo_setting[:component]
                 else
                   compo_setting.delete('menu')
                   Component.new(compo_setting)
                 end
          if Weby::Components.is_enabled?(comp.name)
            visible = comp.visibility == 1 ? current_page?(main_app.site_path) : comp.visibility == 2 ? !current_page?(main_app.site_path) : comp.visibility == 0
            if visible
              if comp.is_group?
                content_for_components "group_#{comp.id}", compo_setting[:children]
              end
              content_for "layout_#{place}".to_sym, render_component(Weby::Components.factory(comp))
            end
          end
        end if comps
      end
      private :content_for_components

      def render_component(component, view = 'show', args = {})
        args[:partial] = "#{component.name}/views/#{view}"

        args[:locals] ||= {}
        args[:locals].merge!(component: component)

        # Caso a partial não exista, não mostra nada
        begin
          if Weby::Assets.find_asset("#{component.name}.css")
            @stylesheets_loaded ||= []
            # Incluir o css do componente somente uma vez, mesmo se existirem mais de um sendo exibido
            unless @stylesheets_loaded.include?(component.name)
              content_for :components_stylesheets, stylesheet_link_tag("#{component.name}")
              @stylesheets_loaded << component.name
            end
          end
          output = render args
          comp_id = component.respond_to?(:html_id) && component.html_id.present? ? component.html_id : "component_#{component.id}"
          output = output.sub(/(class=\".+_component.*\")/, "\\1 id=\"#{comp_id}\"")
        rescue ActionView::MissingTemplate
          output = ''
        end
        raw output
      end

      # Inclui somente uma vez, mesmo se chamado várias vezes,
      # por exemplo se o mesmo componente foi incluido mais de uma vez
      def include_component_javascript(content_for, javascript_name)
        javascript_name = "#{javascript_name}.js" unless javascript_name.to_s.match(/\.js$/)
        if Weby::Assets.find_asset(javascript_name)
          @javascripts_loaded ||= []
          # Incluir o js somente uma vez, mesmo se existirem mais de um componente sendo exibido
          unless @javascripts_loaded.include?(javascript_name)
            content_for content_for, javascript_include_tag(javascript_name)
            @javascripts_loaded << javascript_name
          end
        end
      end
    end

    module Form
      def component_i18n_input(locale, attribute_name, options = {}, &block)
        options[:input_html] = (options[:input_html] || {}).merge(
          value: @object.respond_to?("#{attribute_name}_i18n".to_sym) ? @object.send("#{attribute_name}_i18n".to_sym, locale.name) : '',
          name: "#{@object_name}[#{attribute_name}][#{locale.name}]",
          id: "#{@object_name}_#{attribute_name}_#{locale.name}")

        input attribute_name, options, &block
      end
    end
  end

  SimpleForm::FormBuilder.include(Weby::Components::Form)
  # ActionView::Helpers::FormBuilder.include(Weby::Components::Form)

  module ComponentInheritance
    def inherited(cbase)
      super cbase
      cbase.class_eval do
        # Como do componente que será usando em algumas partes do sistema
        # TODO
        def self.cname
          # Por padrão toda classe componente terá o "Component" no fim do nome, o come do
          # componente não precisa ter esse final
          # ex: GovBarComponent.tableize # => gov_bar_component.gsub(...) => gov_bar
          name.tableize.gsub(/_components$/, '')
        end

        # Inicializa o nome do componente quando ele é criado
        after_initialize do
          self.name = self.class.name.tableize.gsub(/_components$/, '')
        end

        default_scope { where(name: cname) }

        def raw_component
          @raw_compo ||= Weby::Components.components.fetch(name.to_sym, {})
        end
      end
    end
  end

  module ComponentInstance
    def self.extended(base)
      base.class_eval do
        class << self
          prepend(ComponentInheritance)
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
    # Este método deve ser chamado depois de component_settings, nunca antes
    def i18n_settings(*settings)
      settings.each do |setting|
        fail ArgumentError, "Unknown setting for 'i18n_settings' in #{name}: #{setting}. A prior call to 'component_settings' is required" unless public_instance_methods.include? setting.to_sym
        class_eval <<-METHOD
          def #{setting}
            val = settings_map[:#{setting}]
            if val.is_a? Hash
              return val[I18n.locale.to_s].present? ?
                val[I18n.locale.to_s] : val[I18n.default_locale.to_s].present? ?
                   val[I18n.default_locale.to_s] : val.values.sort.last
            end
            val
          end

          def #{setting}_i18n(locale)
            val = settings_map[:#{setting}]
            if val.is_a? Hash
              return val[locale]
            elsif val.is_a? String
              return val if locale == I18n.locale.to_s
            end
            ""
          end
        METHOD
      end
    end
  end
end
