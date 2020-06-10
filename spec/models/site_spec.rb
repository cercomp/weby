require 'rails_helper'

describe Site do
  skip 'Scopes' do
  end

  # context 'url' do
  #   it { expect(subject).to validate_presence_of(:url) }

  #   it 'should accept valid url formats' do
  #     expect(subject).to allow_value('http://www.ufg.br').for(:url)
  #     expect(subject).to allow_value('https://www.test.ufg.br').for(:url)
  #   end

  #   it 'should reject invalid url formats' do
  #     expect(subject).not_to allow_value('www.ufg.br').for(:url)
  #     expect(subject).not_to allow_value('random_string').for(:url)
  #   end
  # end

  context 'name' do
    it { expect(subject).to validate_presence_of(:name) }

    it 'should accept valid name formats' do
      expect(subject).to allow_value('myname300-_').for(:name)
    end

    it 'should reject invalid name formats' do
      expect(subject).not_to allow_value('@#This_should_not_pass').for(:name)
    end
  end

  context 'per_page' do
    it { expect(subject).to validate_presence_of(:per_page) }

    it 'should accept valid per_page formats' do
      expect(subject).to allow_value('10,15,20,25').for(:per_page)
    end

    it 'should reject invalid per_page formats' do
      expect(subject).not_to allow_value('none').for(:per_page)
    end
  end

  it { expect(subject).to validate_presence_of(:title) }
  it { expect(subject).to ensure_length_of(:title).is_at_most(50) }

  it { expect(subject).to have_many(:subsites).class_name('Site').with_foreign_key('parent_id') }
  it { expect(subject).to belong_to(:main_site).class_name('Site').with_foreign_key('parent_id') }

  it { expect(subject).to have_many(:roles) }

  it { expect(subject).to have_many(:views) }

  it { expect(subject).to have_many(:menus).dependent(:destroy).order(:position) }
  it { expect(subject).to have_many(:menu_items).through(:menus) }

  it { expect(subject).to have_many(:pages).dependent(:destroy) }

  it { expect(subject).to have_many(:pages_i18ns).through(:pages) }

  # StickerBanners
  skip { expect(subject).to have_many(:banners).order(:position) }

  it { expect(subject).to have_many(:styles) }
  it { expect(subject).to have_many(:skins) }

  it { expect(subject).to belong_to(:repository).with_foreign_key('top_banner_id') }

  it { expect(subject).to have_many(:repositories) }

  it { expect(subject).to have_many(:extensions) }

  it { expect(subject).to have_and_belong_to_many(:locales) }

  it { expect(subject).to have_and_belong_to_many(:groupings) }

  skip 'Scopes' do
    it 'name_or_description_like' do
      subject = create(:site, name: 'subject', description: 'Description')
      site = create(:site, name: 'site', description: 'Here')

      expect(Site.name_or_description_like('ect')).to include(subject)
      expect(Site.name_or_description_like('ite')).not_to include(subject)
      expect(Site.name_or_description_like('Here')).to include(site)
      expect(Site.name_or_description_like('ption')).not_to include(site)
    end
  end
end
