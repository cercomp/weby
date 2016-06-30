module Weby
  autoload :Extension, 'weby/extension'
  class << self
    @@extensions = {}

    def register_extension(extension)
      @@extensions[extension.name] = extension
    end

    def extensions
      @@extensions
    end

    def generate_search_indexes
      ActiveRecord::Base.connection.execute(%q{
        CREATE INDEX "index_journal_news_i18ns_on_lower_title" ON "journal_news_i18ns" USING btree (LOWER("title"))
      })
      ActiveRecord::Base.connection.execute(%q{
        CREATE INDEX "index_journal_news_i18ns_on_lower_summary" ON "journal_news_i18ns" USING btree (LOWER("summary"))
      })
      ActiveRecord::Base.connection.execute(%q{
        CREATE INDEX "index_journal_news_i18ns_on_lower_text" ON "journal_news_i18ns" USING btree (LOWER("text"))
      })
      ActiveRecord::Base.connection.execute(%q{
        CREATE INDEX "index_users_on_lower_first_name" ON "users" USING btree (LOWER("first_name"))
      })
    end

    def drop_search_indexes
      ActiveRecord::Base.connection.execute(%q{
        DROP INDEX "index_journal_news_i18ns_on_lower_title"
      })
      ActiveRecord::Base.connection.execute(%q{
        DROP INDEX "index_journal_news_i18ns_on_lower_summary"
      })
      ActiveRecord::Base.connection.execute(%q{
        DROP INDEX "index_journal_news_i18ns_on_lower_text"
      })
      ActiveRecord::Base.connection.execute(%q{
        DROP INDEX "index_users_on_lower_first_name"
      })
    end
  end
end
