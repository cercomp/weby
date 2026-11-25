require 'rails_helper'

describe ActivityRecord do
  it { expect(subject).to belong_to(:user) }
  it { expect(subject).to belong_to(:site).optional }

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

    it 'user_or_action_like searches inside differences' do
      user = create(:user, login: 'editor', first_name: 'Editor', password_salt: 'salt', encrypted_password: 'salt')
      record = create(:activity_record, action: 'update', user_id: user.id, differences: { 'date_begin_at' => ['20/11/2026 10:00', '25/11/2026 10:00'] })

      expect(ActivityRecord.user_or_action_like('25/11/2026')).to include(record)
      expect(ActivityRecord.user_or_action_like('20/11/2026')).to include(record)
      expect(ActivityRecord.user_or_action_like('invaliddatestring')).not_to include(record)
    end
  end

  context 'Differences tracking' do
    let(:locale) { Locale.first || create(:locale, name: 'pt-BR') }
    let(:user) { create(:user, login: 'testuser', first_name: 'Test', password_salt: 'salt', encrypted_password: 'salt') }
    let(:site) { create(:site, locales: [locale]) }

    it 'defaults differences to empty hash' do
      record = build(:activity_record, differences: nil)
      expect(record.differences).to eq({})
      expect(record.has_differences?).to be false
    end

    it 'reports has_differences? true when differences are present' do
      record = build(:activity_record, differences: { 'date_begin_at' => ['20/11/2026 10:00', '25/11/2026 10:00'] })
      expect(record.has_differences?).to be true
      expect(record.differences['date_begin_at']).to eq(['20/11/2026 10:00', '25/11/2026 10:00'])
    end

    it 'extracts changes from model date_begin_at' do
      news = Journal::News.create!(
        site: site,
        user: user,
        status: 'draft',
        date_begin_at: Time.zone.parse('2026-11-20 10:00:00'),
        i18ns_attributes: [{ locale_id: site.locales.first.id, title: 'Noticia Original' }]
      )

      news.date_begin_at = Time.zone.parse('2026-11-25 10:00:00')
      news.save!

      changes = ActivityRecord.extract_changes(news)
      expect(changes).to have_key('date_begin_at')
      expect(changes['date_begin_at']).to eq(['20/11/2026 10:00', '25/11/2026 10:00'])
      expect(changes).not_to have_key('updated_at')
    end

    it 'extracts changes from nested i18ns' do
      locale = site.locales.first
      news = Journal::News.create!(
        site: site,
        user: user,
        status: 'draft',
        date_begin_at: Time.current,
        i18ns_attributes: [{ locale_id: locale.id, title: 'Titulo Velho' }]
      )

      i18n = news.i18ns.first
      news.update!(
        i18ns_attributes: [{ id: i18n.id, locale_id: locale.id, title: 'Titulo Novo' }]
      )

      changes = ActivityRecord.extract_changes(news)
      expect(changes).to have_key('title')
      expect(changes['title']).to eq(['Titulo Velho', 'Titulo Novo'])
    end

    it 'formats repository_id into descriptive text' do
      repo1 = create(:repository, site: site, description: 'Foto Antiga', archive_file_name: 'foto1.jpg')
      repo2 = create(:repository, site: site, description: 'Foto Nova', archive_file_name: 'foto2.jpg')

      formatted1 = ActivityRecord.format_value_for_diff(nil, 'repository_id', repo1.id)
      formatted2 = ActivityRecord.format_value_for_diff(nil, 'repository_id', repo2.id)

      expect(formatted1).to include('foto1.jpg')
      expect(formatted2).to include('foto2.jpg')
    end
  end
end
