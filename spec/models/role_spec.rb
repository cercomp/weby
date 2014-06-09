require 'rails_helper'

describe Role do
  it { expect(subject).to validate_presence_of(:name) }
  it { expect(subject).to belong_to(:site) }
  it { expect(subject).to have_and_belong_to_many(:users) }
end
