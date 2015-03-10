module Journal
  class NewsletterHistories < ActiveRecord::Base
    belongs_to :user

    scope :sent, -> (site_id, news_id) {
      where(['site_id = ? AND news_id = ?', site_id, news_id])
    }
  end
end
