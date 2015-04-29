require 'rails_helper'

describe MenuComponent do
  it { should have_setting :menu_id }
  it { should have_setting :dropdown }

  it { should validate_presence_of :menu_id }

  describe '#dropdown' do
    it 'returns false when _dropdown is blank' do
      allow(subject).to receive(:_dropdown).and_return ''

      expect(subject.dropdown).to eq false
    end

    it 'returns true when _dropdown is 1' do
      allow(subject).to receive(:_dropdown).and_return '1'

      expect(subject.dropdown).to eq true
    end

    it 'returns false when _dropdown is diferent from 1' do
      allow(subject).to receive(:_dropdown).and_return '0'

      expect(subject.dropdown).to eq false
    end
  end

  describe '#default_alias' do
    it "returns '' when doesn't find a menu with menu_id" do
      allow(subject).to receive(:menu_id).and_return 1

      allow(Menu).to receive(:find).with(1).and_return nil

      expect(subject.default_alias).to eq ''
    end

    it "returns '' when doesn't find a menu with menu_id" do
      menu = double(:menu, name: 'menu')

      allow(subject).to receive(:menu_id).and_return 1

      allow(Menu).to receive(:find).with(1).and_return menu

      expect(subject.default_alias).to eq menu.name
    end
  end
end
