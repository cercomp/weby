require 'spec_helper'

describe Sticker::Banner do
  it { expect(subject).to belong_to(:page) }
  it { expect(subject).to belong_to(:repository) }
  it { expect(subject).to belong_to(:user) }
  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to validate_presence_of(:title) }
  it { expect(subject).to validate_presence_of(:user_id) }

  it 'should publish default is false' do
    expect(subject.publish).to eql false
  end

  context 'should validate date' do
    before do
      @banner = build(:banner, date_begin_at: nil)
    end
    it { should_not be_valid }
  end

  context 'Scopes' do
    it 'titles_or_texts_like (TITLES)' do
      user = create(:user, login: "user", first_name: "John")

      subject = create(:banner, title: "banner", text: "new text", user_id: user.id)
      banner = create(:banner, title: "another", text: "again", user_id: user.id)

      expect(Sticker::Banner.titles_or_texts_like("ner")).to include(subject)
      expect(Sticker::Banner.titles_or_texts_like("ther")).not_to include(subject)
      expect(Sticker::Banner.titles_or_texts_like("again")).to include(banner)
      expect(Sticker::Banner.titles_or_texts_like("text")).not_to include(banner)
    end

    it 'published' do
      user = create(:user, login: "user", first_name: "John")

      subject = create(:banner, publish: true, date_begin_at: '2013-10-20 03:00:00', user_id: user.id)
      banner = create(:banner, publish: false, user_id: user.id)

      expect(Sticker::Banner.published).to include(subject)
      expect(Sticker::Banner.published).not_to include(banner)
    end
  end
end
