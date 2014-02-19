require 'spec_helper'

describe ActivityRecord do
  it { expect(subject).to belong_to(:user) }
  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to validate_presence_of(:loggeable_id) }
  it { expect(subject).to validate_presence_of(:loggeable_type) }
end
