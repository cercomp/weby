require 'rails_helper'

describe View do
  it { expect(subject).to belong_to(:site) }
  it { expect(subject).to belong_to(:user).optional }
  it { expect(subject).to belong_to(:viewable) }
end
