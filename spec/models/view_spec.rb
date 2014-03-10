require 'spec_helper'

describe View do
  it { expect(subject).to belong_to(:site) }
  it { expect(subject).to belong_to(:user) } 
  it { expect(subject).to belong_to(:viewable) } 

  it { expect(subject).to allow_mass_assignment_of(:ip_address) }
  it { expect(subject).to allow_mass_assignment_of(:query_string) }
  it { expect(subject).to allow_mass_assignment_of(:referer) }
  it { expect(subject).to allow_mass_assignment_of(:user_agent) }
  it { expect(subject).to allow_mass_assignment_of(:request_path) }
  it { expect(subject).to allow_mass_assignment_of(:session_hash) }
  it { expect(subject).to allow_mass_assignment_of(:viewable) }
  it { expect(subject).to allow_mass_assignment_of(:user) }
end
