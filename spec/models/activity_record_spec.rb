require 'spec_helper'

describe ActivityRecord do

  it { expect(subject).to belong_to(:user) }
  it { expect(subject).to belong_to(:site) }
  it { expect(subject).to validate_presence_of(:loggeable_id) }
  it { expect(subject).to validate_presence_of(:loggeable_type) }

  def create_objetcs!
    @activity = create(:activity_record)
    @user = create(:user)
  end
  
end
