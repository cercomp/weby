if ENV['ELASTICSEARCH_URL'].present?
  Searchkick.search_timeout = 4
  if ENV['ELASTICSEARCH_PREFIX'].present?
    Searchkick.index_prefix = ENV['ELASTICSEARCH_PREFIX']
  end
  if ENV['ELASTICSEARCH_ENV'].present?
    Searchkick.env = ENV['ELASTICSEARCH_ENV']
  end
else
  Searchkick.disable_callbacks
end
