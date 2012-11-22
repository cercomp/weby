module Feedback
  class Engine < ::Rails::Engine
    isolate_namespace Feedback

    e = ::Weby::Extension.new
    e.name = 'Feedback'
  end
end
