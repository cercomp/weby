module Journal
  class NewsletterHistories < ActiveRecord::Base
    belongs_to :user
    belongs_to :news

    scope :sent, -> (site_id, news_id) {
      where(['site_id = ? AND news_id = ?', site_id, news_id]).order('created_at DESC')
    }

    scope :get_by_date, -> (site_id, dt_begin, dt_end) {
      where(['site_id = ? AND created_at BETWEEN ? AND ?', site_id, dt_begin, dt_end]).order('created_at DESC')
    }
  end
end
