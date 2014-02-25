require 'spec_helper'

describe Component do
  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to validate_presence_of(:alias) }

  it 'should publish default is true' do
    expect(subject.publish).to eql true
  end

  it 'should place_holder default is home' do
    expect(subject.place_holder).to eql 'home'
  end
end
