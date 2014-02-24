require 'spec_helper'

describe ActivityRecord do
  it { expect(subject).to belong_to(:user) }
  it { expect(subject).to belong_to(:site) }
end
