hosts = ENV['ELASTICSEARCH_URL'].present? ? ENV['ELASTICSEARCH_URL'] : 'localhost:9200'
Searchkick.client = Elasticsearch::Client.new(hosts: [hosts], retry_on_failure: true, transport_options: {request: {timeout: 250}})
if ENV['ELASTICSEARCH_PREFIX'].present?
  Searchkick.index_prefix = ENV['ELASTICSEARCH_PREFIX']
end
if ENV['ELASTICSEARCH_ENV'].present?
  Searchkick.env = ENV['ELASTICSEARCH_ENV']
end
