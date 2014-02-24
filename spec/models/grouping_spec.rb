require 'spec_helper'

describe Grouping do
  it { expect(subject).to validate_presence_of(:name) } 

  context 'Sites' do
    it { expect(subject).to belong_to(:site) }
  end
end
