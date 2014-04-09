require 'spec_helper'

describe Setting do
  it { expect(subject).to validate_uniqueness_of(:name) }
  it { expect(subject).to allow_mass_assignment_of(:default_value) }

  pending 'check_value' do
  end
end
