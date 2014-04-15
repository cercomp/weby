require 'spec_helper'

describe SitesPage do
  it { expect(subject).to belong_to(:site) }
  it { expect(subject).to belong_to(:page) }
end
