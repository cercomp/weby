module Journal
  class NewsPositionObserver < ActiveRecord::Observer
    observe 'journal/news_site'

    # UPDATE
    def before_save(news_site)
      @news_site = news_site
      update_position if @news_site.front_changed? && !@news_site.new_record?
    end

    # CREATE
    def before_validation(news_site)
      @news_site = news_site
      # Sempre seta position
      @news_site.position = 0 if @news_site.position.nil?
      turning_front if @news_site.front && @news_site.new_record?
    end

    def before_destroy(news_site)
      @news_site = news_site
      leaving_fronts
    end

    private

    def update_position
      @news_site.front ? turning_front : leaving_fronts
    end

    def leaving_fronts
      update_fronts_up_me
      @news_site.position = 0
    end

    def update_fronts_up_me
       Journal::NewsSite.where(site_id: @news_site.site_id).front.where("position > #{@news_site.position}")
         .update_all('position = position - 1') if @news_site.position.present?
    end

    def turning_front
      @news_site.position = last_front_position + 1
    end

    def last_front_position
      @position = Journal::NewsSite.available_fronts.where(site: @news_site.site_id)
      @position.maximum(:position).to_i
    end
  end
end
