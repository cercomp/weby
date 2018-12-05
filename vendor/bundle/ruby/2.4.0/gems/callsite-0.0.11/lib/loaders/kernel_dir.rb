module Kernel
  def __DIR_REL__(called_from = nil)
    parsed_line = Callsite.parse(called_from || caller.first)
    parsed_line && File.expand_path(File.dirname(parsed_line.filename))
  end

  unless method_defined?(:__DIR__)
    alias_method :__DIR__, :__DIR_REL__
  end

  unless method_defined?(:require_relative)
    def require_relative(path)
      require File.join(__DIR_REL__(caller.first), path)
    end
  end
end
  