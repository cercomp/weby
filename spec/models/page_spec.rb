require 'rails_helper'

describe Page do
  it { expect(subject).to belong_to(:owner).class_name('Site') }
  it { expect(subject).to belong_to(:owner).with_foreign_key('site_id') }

  it { expect(subject).to belong_to(:user).class_name('User') }

  it { expect(subject).to belong_to(:image).class_name('Repository') }
  it { expect(subject).to belong_to(:image).with_foreign_key('repository_id') }

  it { expect(subject).to have_many(:views) }
  it { expect(subject).to have_many(:menu_items).dependent(:nullify) }
  it { expect(subject).to have_many(:posts_repositories).dependent(:destroy) }
  it { expect(subject).to have_many(:related_files).through(:posts_repositories) }

  it { expect(subject).to validate_presence_of(:user_id) }
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
    skip 'should only return published pages' do
      subject = build(:page, publish: true)
      page = build(:page, publish: false)

      expect(subject).to respond_to(:published)
      expect(page).not_to respond_to(:published)
    end
  end

  describe '#to_param' do
    it "parameteize the string 'id title'" do
      allow(subject).to receive(:id).and_return 1
      allow(subject).to receive(:title).and_return 'Titulo'

      expect(subject.to_param).to eq('1-titulo')
    end
  end

  describe '#event?' do
    it 'returns true when type is event' do
      subject.type = 'Event'

      expect(subject.event?).to eq(true)
    end

    it "returns false when type isn't event" do
      subject.type = 'Page'

      expect(subject.event?).to eq(false)
    end
  end

  describe '#image=' do
    it "set repository_id to file if file isn't a repository" do
      file = 1

      expect(subject.image=(file)).to eq 1
    end

    it 'set repository_id to file id if file is a repository' do
      file = Repository.new(id: 1)

      subject.image=(file)

      expect(subject.repository_id).to eq file.id
    end
  end

  describe '.uniq_category_counts' do
    it 'returns an array of ActsAsTaggableOn::Tag' do
      2.times do
        page = Page.new
        page.category_list.add('categoria 1')
        page.save(validate: false)
      end

      2.times do
        page = Page.new
        page.category_list.add('categoria 2')
        page.save(validate: false)
      end

      expect(Page.uniq_category_counts).to eq Page.category_counts
    end
  end

  skip 'self.import' do
  end
end
