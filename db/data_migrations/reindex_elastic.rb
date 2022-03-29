if ENV['ELASTICSEARCH_URL'].present?
    Journal::NewsSite.reindex
    Calendar::Event.reindex
    Page.reindex
end