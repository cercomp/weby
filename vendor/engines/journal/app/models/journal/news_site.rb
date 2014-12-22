module Journal
  class NewsSite < ActiveRecord::Base
    belongs_to :site
    belongs_to :journal_news
  end
end

#Nesse model q criou é belongs_to :site
#E belongs_to :news
#
#E pra fazer o through, tem q ter
#has_many :news_sites
#No model News
#E nao existe :new no singular
#
#Dai no model News tem q ficar has_many :news_sites
#
#E has_many :sites, through: :news_sites
