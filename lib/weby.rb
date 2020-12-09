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
      create_lower_index "journal_news_i18ns", "title"
      create_lower_index "journal_news_i18ns", "summary"
      create_lower_index "journal_news_i18ns", "text"
      create_lower_index "users", "first_name"
    end

    def drop_search_indexes
      drop_lower_index "journal_news_i18ns", "title"
      drop_lower_index "journal_news_i18ns", "summary"
      drop_lower_index "journal_news_i18ns", "text"
      drop_lower_index "users", "first_name"
    end

    def run_data_migration file_name
      if file_name.present?
        return load(Rails.root.join('db', 'data_migrations', "#{file_name}.rb"))
      end
      return false
    end

    private
    def create_lower_index table, field
      begin
        ActiveRecord::Base.connection.execute(%Q{
          CREATE INDEX "index_#{table}_on_lower_#{field}" ON "#{table}" USING btree (LOWER("#{field}"))
        })
      rescue Exception => e
        puts e
        #We can live without indexes
      end
    end

    def drop_lower_index table, field
      begin
        ActiveRecord::Base.connection.execute(%Q{
          DROP INDEX "index_#{table}_on_lower_#{field}"
        })
      rescue Exception => e
        puts e
        #Hmm maybe the index was not created
      end
    end
  end
end
