require 'spec_helper'

describe Grouping do
  it { expect(subject).to validate_presence_of(:name) } 

  context 'Sites' do
    it { expect(subject).to has_and_belongs_to_many(:site) }
  end
end
