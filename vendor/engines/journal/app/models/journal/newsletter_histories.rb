module Journal
  class NewsletterHistories < Journal::ApplicationRecord
    belongs_to :user
    belongs_to :news, -> { unscope(where: :deleted_at) }

    scope :sent, -> (site_id, news_id) {
      where(['site_id = ? AND news_id = ?', site_id, news_id]).order('created_at DESC')
    }

    scope :get_by_date, -> (site_id, dt_begin, dt_end) {
      where(['site_id = ? AND created_at BETWEEN ? AND ?', site_id, dt_begin, dt_end+" 23:59:59"]).order('created_at DESC')
    }
  end
end
