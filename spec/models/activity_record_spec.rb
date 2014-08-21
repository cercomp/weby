require 'rails_helper'

describe ActivityRecord do
  it { expect(subject).to belong_to(:user) }
  it { expect(subject).to belong_to(:site) }

  context 'Scopes' do
    it 'user_or_action_like (ACTION)' do
      site = build(:site)

      user1 = create(:user, login: 'user', first_name: 'John', password_salt: 'salt', encrypted_password: 'salt')
      user2 = create(:user, login: 'login', first_name: 'James', password_salt: 'salt', encrypted_password: 'salt')

      subject = create(:activity_record, action: 'Create', user_id: user1.id)
      record = create(:activity_record, action: 'Destroy', user_id: user2.id)

      expect(ActivityRecord.user_or_action_like('ate', site.id)).to include(subject)
      expect(ActivityRecord.user_or_action_like('troy', site.id)).not_to include(subject)
      expect(ActivityRecord.user_or_action_like('James', site.id)).to include(record)
      expect(ActivityRecord.user_or_action_like('John', site.id)).not_to include(record)
    end
  end
end
