if ENV['ELASTICSEARCH_URL'].present?
  Searchkick.client = Elasticsearch::Client.new(
    hosts: [ENV['ELASTICSEARCH_URL']],
    retry_on_failure: true,
    transport_options: {request: {timeout: 250}}
  )
  if ENV['ELASTICSEARCH_PREFIX'].present?
    Searchkick.index_prefix = ENV['ELASTICSEARCH_PREFIX']
  end
  if ENV['ELASTICSEARCH_ENV'].present?
    Searchkick.env = ENV['ELASTICSEARCH_ENV']
  end
else
  Searchkick.disable_callbacks
end
