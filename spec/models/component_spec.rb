require 'spec_helper'

describe Component do
  it { expect(subject).to belong_to(:site) }

  pending { expect(subject).to validate_presence_of(:alias) }

  it 'should publish default is true' do
    expect(subject.publish).to eql true
  end

  context 'before_save' do
    before do
      component = Component.new(publish: false)
      component.save
    end

    it { should_not be_valid }
  end

  pending 'after_destroy' do
  end

  pending 'self.import' do
  end
end
