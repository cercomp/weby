require 'spec_helper'

describe Grouping do
  it { expect(subject).to validate_presence_of(:name) } 

  it { expect(subject).to allow_mass_assignment_of(:name) }
  it { expect(subject).to allow_mass_assignment_of(:site_ids) }

  context 'Sites' do
    it { expect(subject).to have_and_belong_to_many(:sites) }
  end
end
