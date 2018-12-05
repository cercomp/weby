$LOAD_PATH.instance_eval do
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
    add(__DIR_REL__(caller.first))
  end

  def add_current!
    add!(__DIR_REL__(caller.first))
  end

  def add(path)
    push(path) unless include?(path)
  end

  def add!(path)
    delete(path)
    unshift(path)
  end
end