require 'rails_helper'

describe Notification do
  it { expect(subject).to belong_to(:user) }

  it { expect(subject).to validate_presence_of(:title) }
  it { expect(subject).to validate_presence_of(:body) }

  context 'Scopes' do
    it 'title_or_body_like' do
      user = create(:user, login: 'user', first_name: 'John', password_salt: 'salt', encrypted_password: 'salt')

      subject = create(:notification, title: 'Title', body: 'Body', user_id: user.id)
      notif = create(:notification, title: 'Notification', body: 'Content', user_id: user.id)

      expect(Notification.title_or_body_like('tle')).to include(subject)
      expect(Notification.title_or_body_like('cation')).not_to include(subject)
      expect(Notification.title_or_body_like('ent')).to include(notif)
      expect(Notification.title_or_body_like('ody')).not_to include(notif)
    end
  end
end
