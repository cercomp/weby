require 'rails_helper'

describe UserLoginHistory do
  it { expect(subject).to belong_to(:user) }
end
