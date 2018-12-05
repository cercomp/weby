require 'callsite/version'

module Callsite
  UnparsableCallLine = Class.new(RuntimeError)
  Line = Struct.new(:filename, :line, :method)

  def self.__DIR_REL__(called_from = nil)
    called_from ||= caller.first
    caller_path = parse(called_from).filename
    caller_path = '.' if caller_path == ''
    File.expand_path(File.dirname(caller_path))
  end

  def self.parse(input)
    if input.respond_to?(:backtrace)
      parse(input.backtrace)
    elsif input.is_a?(Array)
      block_given? ?
        input.each{|line| yield parse(line)} :
        input.map{|line| parse(line)}
    else
      if match = input.match(/^(.*?)(:(\d+))(:in `(.*)')?$/)
        Line.new(match[1], match[3].to_i, match[5])
      else
        raise UnparsableCallLine.new("unable to parse #{input}")
      end
    end
  end
  
  def self.activate_string_methods
    activate_kernel_dir_methods
    ::String.send(:include, StringMethods)
  end
  
  def self.activate_file_methods
    activate_kernel_dir_methods
    ::File.send(:extend, FileMethods)
  end
  
  def self.activate_module_methods
    activate_kernel_dir_methods
    ::Module.send(:include, ModuleMethods)
  end
  
  def self.activate_kernel_dir_methods
    require 'loaders/kernel_dir'
  end
  
  def self.activate_kernel_require_methods
    activate_loadpath_methods
    require 'loaders/kernel_require'
  end
  
  def self.activate_loadpath_methods
    activate_kernel_dir_methods
    require 'loaders/load_path'
  end
  
  def self.activate_all
    activate_string_methods
    activate_file_methods
    activate_module_methods
    activate_kernel_dir_methods
    activate_kernel_require_methods
    activate_loadpath_methods
  end
  
  module StringMethods
    unless method_defined?(:~@)
      def ~@
        File.expand_path(File.join(Kernel.__DIR_REL__(caller.first), self))
      end
    end
  end

  module FileMethods
    def relative(path)
      File.expand_path(File.join(Kernel.__DIR_REL__(caller.first), path))
    end
  end

  module ModuleMethods
    unless method_defined?(:autoload_relative)
      def autoload_relative(name, filename)
        autoload name, File.join(Kernel.__DIR_REL__(caller.first), filename)
      end
    end
  end
  
  module LoadPathMethods
    def find_file(file)
      find_all_files(file){|f| return f}
      nil
    end

    def find_all_files(file, ext = nil)
      file += ext if ext and File.extname(file) != ext
      inject([]){|ary, path| 
        target = File.expand_path(file, path)
        if File.readable?(target)
          ary << target
          yield target if block_given?
        end
        ary
      }
    end

    def add_current
      self << __DIR_REL__(caller.first)
    end

    def add_current!
      self.unshift(__DIR_REL__(caller.first))
    end
  end
end