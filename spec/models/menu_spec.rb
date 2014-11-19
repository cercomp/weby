require 'rails_helper'

describe Menu do
  it { expect(subject).to validate_presence_of(:name) }
  it { expect(subject).to validate_presence_of(:site) }

  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to have_many(:menu_items).dependent(:destroy) }
  it { expect(subject).to have_many(:root_menu_items).class_name('MenuItem') }

  context '#items_by_parent' do
    before do
      @item1 = double(:item1, parent_id: 1, published: true)
      @item2 = double(:item2, parent_id: 2, published: true)
      @item3 = double(:item3, parent_id: 3, published: false)
      @items_published = double(published: [@item1, @item2])
      @items = double(menu_items: [@item1, @item2, @item3])
    end

    it 'returns menu items published grouped by parent_id' do
      allow(subject).to receive(:menu_items).and_return @items
      allow(@items).to receive(:published).and_return @items_published.published

      expect(subject.items_by_parent(true)).to eq(1 => [@item1], 2 => [@item2])
    end

    it 'returns all menu items grouped by parent_id' do
      allow(subject).to receive(:menu_items).and_return @items.menu_items

      expect(subject.items_by_parent(false)).to eq(1 => [@item1], 2 => [@item2], 3 => [@item3])
    end

  end

  skip 'self.import' do
  end
end
