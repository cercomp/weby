Site.all.each do |site|
  site.per_page = Site.columns_hash['per_page'].default
  site.save
end
