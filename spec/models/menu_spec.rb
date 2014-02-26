require 'spec_helper'

describe Menu do
  it { expect(subject).to validate_presence_of(:name) }
  it { expect(subject).to validate_presence_of(:site_id) }
  it { expect(subject).to validate_numericality_of(:site_id) }

  it { expect(subject).to belong_to(:site) }

  it { expect(subject).to have_many(:menu_items).dependent(:destroy) }

  it { expect(subject).to have_many(:root_menu_items).class_name('MenuItem') }
end
