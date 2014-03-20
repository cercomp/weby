require 'spec_helper'

describe Page do
  it { expect(subject).to belong_to(:owner).class_name('Site') }
  it { expect(subject).to belong_to(:owner).with_foreign_key('site_id') }

  it { expect(subject).to belong_to(:author).class_name('User') }

  it { expect(subject).to belong_to(:image).class_name('Repository') }
  it { expect(subject).to belong_to(:image).with_foreign_key('repository_id') }

  it { expect(subject).to have_many(:views) }
  it { expect(subject).to have_many(:menu_items).dependent(:nullify) }
  it { expect(subject).to have_many(:banners).dependent(:nullify) }
  it { expect(subject).to have_many(:pages_repositories).dependent(:destroy) }
  it { expect(subject).to have_many(:related_files).through(:pages_repositories) }

  it { expect(subject).to validate_presence_of(:author_id) }
  it { expect(subject).to validate_presence_of(:site_id) }

  context 'position' do
    it 'position should be default false' do
      expect(subject).not_to validate_presence_of(:position)
    end
    it 'should accept position to be true' do
      expect(subject).to allow_value(true).for(:position)
    end
  end

  context 'type' do
    it { expect(subject).to validate_presence_of(:type) }

    it 'should accept valid types' do
      expect(subject).to allow_value('News').for(:type)
      expect(subject).to allow_value('Event').for(:type)
    end

    it 'should not accept invalid types' do
      expect(subject).not_to allow_value('Banner').for(:type)
    end
  end

  context 'kind' do
    it { expect(subject).to validate_presence_of(:type) }

    it 'should accept only valid kinds' do
      expect(subject).to allow_value('regional').for(:kind)
      expect(subject).to allow_value('national').for(:kind)
      expect(subject).to allow_value('international').for(:kind)
    end

    it 'should not accept invalid kinds' do
      expect(subject).not_to allow_value('not regional').for(:kind)
    end
  end

  context 'local' do
    it 'local should be default false' do
      expect(subject).not_to validate_presence_of(:local)
    end

    it 'should accept local to be true' do
      expect(subject).to allow_value(true).for(:position)
    end
  end

  context 'Scopes' do
    pending 'should only return published pages' do
      subject = build(:page, publish: true)
      page = build(:page, publish: false)

      expect(subject).to respond_to(:published)
      expect(page).not_to respond_to(:published)
      #expect(Page.published).to eql [subject]
    end
  end
end
