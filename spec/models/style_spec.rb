require 'rails_helper'

describe Style do
  it { expect(subject).to belong_to(:skin) }
  it { expect(subject).to belong_to(:style) }

  it { expect(subject).to have_many(:styles).dependent(:restrict_with_error) }
  it { expect(subject).to have_many(:followers).through(:styles) }

  it { expect(subject).to validate_presence_of(:skin) }
  it { expect(subject).to validate_presence_of(:name) }

  context 'when has style' do
    before do
      @style = double(
        :style,
        css: 'css',
        name: 'name',
        site: 'site',
        style: nil
      )
    end

    it 'does not validate present of name' do
      allow(subject).to receive(:style).and_return(@style)

      expect(subject).to_not validate_presence_of(:name)
    end

    describe '#original' do
      it 'returns style as original' do
        allow(subject).to receive(:style).and_return(@style)

        expect(subject.original).to eq(@style)
      end
    end

    describe '#css' do
      it 'returns the style css' do
        allow(subject).to receive(:style).and_return(@style)

        expect(subject.css).to eq('css')
      end
    end

    describe '#name' do
      it 'returns the style name' do
        allow(subject).to receive(:style).and_return(@style)

        expect(subject.name).to eq('name')
      end
    end

    describe '#owner' do
      it 'returns the site of the style' do
        allow(subject).to receive(:style).and_return(@style)

        expect(subject.owner).to eq('site')
      end
    end
  end

  context "when hasn't style" do
    describe '#original' do
      it 'returns self as original style' do
        expect(subject.original).to eq(subject)
      end
    end

    describe '#css' do
      it 'reads attribute css' do
        css = double(:css)

        allow(subject).to receive(:css).and_return(css)

        expect(subject.css).to eq(css)
      end
    end

    describe '#name' do
      it 'reads attribute name' do
        name = double(:name)

        allow(subject).to receive(:name).and_return(name)

        expect(subject.name).to eq(name)
      end
    end

    describe '#owner' do
      it 'returns site when dont have a style' do
        site = double(:site)

        allow(subject).to receive(:site).and_return(site)

        expect(subject.owner).to eq(site)
      end
    end
  end

  describe '#copy!' do
    it "returns false when copy to own site and hasn't style_id" do
      site = double(:site)

      allow(subject).to receive(:site).and_return(site)

      expect(subject.copy!(site)).to eq(false)
    end

    it 'updates css, name, and style_id when copy to own site' do
      site = double(:site)
      style = double(:style, name: 'name', css: 'css')

      allow(subject).to receive(:site).and_return(site)
      allow(subject).to receive(:style).and_return(style)
      allow(subject).to receive(:update).with(css: 'css', name: 'name', style_id: nil)

      subject.copy!(site)
    end

    it "returns false when copy to diferent site and hasn't style_id" do
      site = double(:site)
      site2 = double(:site2)

      allow(subject).to receive(:site).and_return(site2)
      allow(subject).to receive(:style_id).and_return(1)

      expect(subject.copy!(site)).to eq(false)
    end

    it 'create a new style when copy to a diferent site' do
      site = double(:site)
      site2 = double(:site2)
      name = double(:name)
      css = double(:css)
      skin = double(:skin)

      allow(subject).to receive(:site).and_return(site2)
      allow(subject).to receive(:name).and_return(name)
      allow(subject).to receive(:css).and_return(css)
      allow(Style).to receive(:create!).with(css: css, name: name, skin: skin)
      allow(site).to receive(:active_skin).and_return(skin)

      subject.copy!(site)
    end
  end

  describe 'position after create' do
    it 'should set max position after creation' do
      locale = create(:locale)
      site = create(:site, locales: [locale])
      skin = create(:skin, site_id: site.id)
      style1 = create(:style, skin_id: skin.id)
      style2 = create(:style, skin_id: skin.id)
      style3 = create(:style, skin_id: skin.id)

      expect([style1.position, style2.position, style3.position]).to eq([1,2,3])
    end
  end

  skip '.import'
end
