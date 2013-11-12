require 'spec_helper'

describe Style do
  it { expect(subject).to belong_to(:owner).class_name('Site') }
  it { expect(subject).to belong_to(:owner).class_name('Site') }

  it { expect(subject).to have_many(:sites_styles).dependent(:destroy) }
  it { expect(subject).to have_many(:followers).through(:sites_styles) }

  it { expect(subject).to accept_nested_attributes_for(:sites_styles) }

  it { expect(subject).to validate_presence_of(:name) }
  it { expect(subject).to validate_presence_of(:owner) }

  it 'should publish is default true' do
    subject = Style.new

    expect(subject.publish).to eq true
  end

  context 'scopes' do
    before do
      create_objects!
    end

    it 'by_name' do
      pending 'Escrever em integration'
      subject = Style.by_name @style_1.name

      expect(subject).to eq [@style_1]
      expect(subject).to_not eq [@style_2]
      expect(subject).to_not eq [@style_1, @style_2]
    end

    it 'by' do
      pending 'Escrever em integration'
      subject = Style.by @site_1.id

      expect(subject).to eq [@style_1]
      expect(subject).to_not eq [@style_2]
      expect(subject).to_not eq [@style_1, @style_2]
    end

    it 'not_followed_by' do
      pending 'Escrever em integration'
    end
  end

  def create_objects!
    @locale = create(:locale)
    @site_1 = create(:site, locales: [@locale])
    @site_2 = create(:site, locales: [@locale])
    @style_1 = create(:style, owner: @site_1)
    @style_2 = create(:style, owner: @site_2)
  end
end
