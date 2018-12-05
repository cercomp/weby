module Kernel
  def require_all(req)
    $LOAD_PATH.find_all_files(req, ".rb") { |file| require file }
  end

  def require_next(req)
    found, current = false, File.expand_path(caller.first[/(.*)(:\d+)/,1])
    $LOAD_PATH.find_all_files(req, ".rb") do |file|
      if found
        $LOADED_FEATURES << req
        return require(file)
      else
        found = current == file
      end
    end
    require req
  end
end