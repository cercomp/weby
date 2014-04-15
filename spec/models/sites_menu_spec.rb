require 'spec_helper'

describe SitesMenu do
  it { expect(subject).to belong_to(:site) }
  it { expect(subject).to belong_to(:menu) }
end
