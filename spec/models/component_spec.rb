require 'spec_helper'

describe Component do
  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to validate_presence_of(:alias) }

  it 'should publish default is true' do
    expect(subject.publish).to eql true
  end

  pending 'before_save' do
  end

  pending 'after_save' do
  end

  pending 'after_destroy' do
  end
end
