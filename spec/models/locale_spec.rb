require 'rails_helper'

describe Locale do
  it { expect(subject).to have_and_belong_to_many(:sites) }
  it { expect(subject).to have_many(:news).class_name('Page::I18ns')  }

  skip 'self.import' do
  end
end
