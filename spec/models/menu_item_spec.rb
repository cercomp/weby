require 'spec_helper'

describe MenuItem do
  it { expect(subject).to belong_to(:menu) }
  it { expect(subject).to validate_presence_of(:menu_id) }

  it { expect(subject).to belong_to(:parent).class_name('MenuItem') }
  it { expect(subject).to have_many(:children).dependent(:destroy) }
  it { expect(subject).to have_many(:children).class_name('MenuItem') }
  it { expect(subject).to have_many(:children).with_foreign_key('parent_id') }

  it { expect(subject).to validate_numericality_of(:position) }
end
