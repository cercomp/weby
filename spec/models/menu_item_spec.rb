require 'rails_helper'

describe MenuItem do
  it { expect(subject).to belong_to(:menu) }
  it { expect(subject).to validate_presence_of(:menu_id) }

  it { expect(subject).to belong_to(:parent).class_name('MenuItem') }

  it { expect(subject).to have_many(:children).dependent(:destroy) }
  it { expect(subject).to have_many(:children).class_name('MenuItem') }
  it { expect(subject).to have_many(:children).with_foreign_key('parent_id') }

  it { expect(subject).to validate_numericality_of(:position) }

  context 'html_class' do
    it 'should accept valid name for html class' do
      expect(subject).to allow_value('classe001_-').for(:html_class)
    end
  end

  skip 'after_save' do
  end

  skip 'update_positions' do
  end

  skip 'self.import' do
  end
end
