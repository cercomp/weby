module Journal
  class Newsletter < Journal::ApplicationRecord
    scope :by_site, ->(id) {
      where(['confirm = ? AND site_id = ?', true, id]) 
    }

    scope :show_emails, ->(id) {
      (by_site(id).map &:email).join("; ")
    }

    scope :selected_emails, ->(ids) {
      result = ""
      Journal::Newsletter.order('email').find(ids.split(",").map(&:to_i)).each do |reg|
        result << reg.email+ "; "
      end
      return result
    }
  end
end
