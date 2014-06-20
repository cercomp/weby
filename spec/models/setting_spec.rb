require 'rails_helper'

describe Setting do
  it { expect(subject).to validate_uniqueness_of(:name) }

  skip 'check_value' do
  end
end
