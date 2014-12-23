module Journal
  class NewsSite < ActiveRecord::Base
    belongs_to :site
    belongs_to :journal_news
  end
end
