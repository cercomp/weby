require 'spec_helper'

describe Extension do
  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to allow_mass_assignment_of(:site_id) }
  it { expect(subject).to allow_mass_assignment_of(:name) }

  it { expect(subject).to validate_presence_of(:name) }
  it { expect(subject).to validate_presence_of(:site) }
end
