require 'spec_helper'

describe Banner do
  it { expect(subject).to belong_to(:page) }
  it { expect(subject).to belong_to(:repository) }
  it { expect(subject).to belong_to(:user) }
  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to validate_presence_of(:title) }
  it { expect(subject).to validate_presence_of(:user_id) }

  it 'should publish default is false' do
    expect(subject.publish).to eql false
  end
end
