require 'rails_helper'

describe Extension do
  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to validate_presence_of(:name) }
  it { expect(subject).to validate_presence_of(:site) }

  skip 'self.import' do
  end
end
