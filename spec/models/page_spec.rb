require 'rails_helper'

describe Page do
  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to belong_to(:user).class_name('User') }

  it { expect(subject).to have_many(:views) }
  it { expect(subject).to have_many(:menu_items).dependent(:nullify) }
  skip { expect(subject).to have_many(:posts_repositories).dependent(:destroy) }
  it { expect(subject).to have_many(:related_files).through(:posts_repositories) }

  it { expect(subject).to validate_presence_of(:user_id) }
  it { expect(subject).to validate_presence_of(:site_id) }

  context 'position' do
    skip 'position should be default false' do
      expect(subject).not_to validate_presence_of(:position)
    end
    skip 'should accept position to be true' do
      expect(subject).to allow_value(true).for(:position)
    end
  end

  context 'type' do
    skip { expect(subject).to validate_presence_of(:type) }

    skip 'should accept valid types' do
      expect(subject).to allow_value('News').for(:type)
      expect(subject).to allow_value('Event').for(:type)
    end

    skip 'should not accept invalid types' do
      expect(subject).not_to allow_value('Banner').for(:type)
    end
  end

  context 'kind' do
    skip { expect(subject).to validate_presence_of(:type) }

    skip 'should accept only valid kinds' do
      expect(subject).to allow_value('regional').for(:kind)
      expect(subject).to allow_value('national').for(:kind)
      expect(subject).to allow_value('international').for(:kind)
    end

    skip 'should not accept invalid kinds' do
      expect(subject).not_to allow_value('not regional').for(:kind)
    end
  end

  context 'local' do
    skip 'local should be default false' do
      expect(subject).not_to validate_presence_of(:local)
    end

    skip 'should accept local to be true' do
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
    skip 'returns true when type is event' do
      subject.type = 'Event'

      expect(subject.event?).to eq(true)
    end

    skip "returns false when type isn't event" do
      subject.type = 'Page'

      expect(subject.event?).to eq(false)
    end
  end

  describe '#image=' do
    skip "set repository_id to file if file isn't a repository" do
      file = 1

      expect(subject.image = (file)).to eq 1
    end

    skip 'set repository_id to file id if file is a repository' do
      file = Repository.new(id: 1)

      subject.image = (file)

      expect(subject.repository_id).to eq file.id
    end
  end

  describe '.uniq_category_counts' do
    skip 'returns an array of ActsAsTaggableOn::Tag' do
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
