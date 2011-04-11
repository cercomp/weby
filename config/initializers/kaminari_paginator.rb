module Kaminari
  DEFAULT_PER_PAGE = Site.columns_hash['per_page'].default.
      gsub(/[^\d,]/,'').split(',').first.to_i
end
