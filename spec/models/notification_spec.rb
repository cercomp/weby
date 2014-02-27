require 'spec_helper'

describe Notification do
  it { expect(subject).to belong_to(:user) }

  it { expect(subject).to validate_presence_of(:title) }
  it { expect(subject).to validate_presence_of(:body) }
end
