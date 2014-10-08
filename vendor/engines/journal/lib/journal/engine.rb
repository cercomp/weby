module Journal
  class Engine < ::Rails::Engine
#    engine_name(generate_railtie_name(Journal.name))
#    self.isolated = true
#
#    unless Journal.respond_to?(:railtie_namespace)
#      name, railtie = engine_name, self
#
#      Journal.singleton_class.instance_eval do
#        define_method(:railtie_namespace) { railtie }
#
#        unless Journal.respond_to?(:table_name_prefix)
#          define_method(:table_name_prefix) { "#{name}_" }
#        end
#
#        unless Journal.respond_to?(:use_relative_model_naming?)
#          class_eval "def use_relative_model_naming?; true; end", __FILE__, __LINE__
#        end
#      end
#    end
  end
end
