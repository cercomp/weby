module Journal
  class NewsPositionObserver < ActiveRecord::Observer
    observe 'journal/news'


    # UPDATE
    def before_save(news)
      @news = news
      update_position if @news.front_changed? && !@news.new_record?
    end

    # CREATE
    def before_validation(news)
      @news = news
      # Sempre seta position
      @news.position = 0 if @news.position.nil?
      turning_front if @news.front && @news.new_record?
    end

    def before_destroy(news)
      @news = news
      leaving_fronts
    end

    private

    def update_position
      @news.front ? turning_front : leaving_fronts
    end

    def leaving_fronts
      update_fronts_up_me
      @news.position = 0
      @news_site = Journal::NewsSite.where(journal_news_id: @news.id, site: @news.site_id).first
      @news_site.front = false
      @news_site.save
      @news_site.position = 0
    end

    def update_fronts_up_me
      Journal::NewsSite.where(site_id: @news.site_id).front.where("position > #{@news.position}")
        .update_all('position = position - 1') if @news.position.present?
      @news_site = Journal::NewsSite.where(journal_news_id: @news.id, site: @news.site_id)
      @news_site.update_all('position = position - 1')
#      Journal::NewsSite.where(journal_news: Journal::News.where(site: 1).first.id).first
    end

    def turning_front
      @news.position = last_front_position + 1
      @news_site = Journal::NewsSite.where(journal_news_id: @news.id, site: @news.site_id).first
      @news_site.front = true
      @news_site.save
      @news_site.position = last_front_position + 1
    end

    def last_front_position
      @news_site = Journal::NewsSite.where(journal_news_id: @news.id, site: @news.site_id)
      @news_site.maximum('position').to_i
    end
  end
end
