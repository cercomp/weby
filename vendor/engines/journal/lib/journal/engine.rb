module Journal
  class Engine < ::Rails::Engine
    #TODO move this block to somewhere reusable
    mod = Journal
    engine_name(generate_railtie_name(mod.name))
    self.routes.default_scope = {}
    self.isolated = true
    unless mod.respond_to?(:railtie_namespace)
      name, railtie = engine_name, self
      mod.singleton_class.instance_eval do
        define_method(:railtie_namespace) { railtie }
        unless mod.respond_to?(:table_name_prefix)
          define_method(:table_name_prefix) { "#{name}_" }
        end
        unless mod.respond_to?(:use_relative_model_naming?)
          class_eval "def use_relative_model_naming?; true; end", __FILE__, __LINE__
        end
      end
    end

    (config.active_record.observers ||= []) << 'journal/news_position_observer'
  end
end
