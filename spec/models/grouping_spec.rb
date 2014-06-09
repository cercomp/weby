require 'rails_helper'

describe Grouping do
  it { expect(subject).to validate_presence_of(:name) }

  context 'Sites' do
    it { expect(subject).to have_and_belong_to_many(:sites) }
  end
end
