module Journal
  class NewsSite < ActiveRecord::Base
    belongs_to :site
    belongs_to :news, class_name: "::Journal::News", foreign_key: "journal_news_id"

    validate :validate_position

    private
    
    def validate_position
      self.position = last_front_position + 1
#      self.position = 0 if self.position.nil?
    end

    scope :front, -> { where(front: true) }
    scope :no_front, -> { where(front: false) }
    scope :available, -> { where('date_begin_at is NULL OR date_begin_at <= :time', time: Time.now) }
    scope :available_fronts, -> { front.where('date_end_at is NULL OR date_end_at > :time', time: Time.now) }

    # tipos de busca
    # 0 = "termo1 termo2"
    # 1 = termo1 AND termo2
    # 2 = termo1 OR termo2
    
    def last_front_position
      @news_site = Journal::NewsSite.where(site: self.site_id).front
      @news_site.maximum('position').to_i
    end

  end
end
