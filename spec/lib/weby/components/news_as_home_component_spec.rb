require 'rails_helper'

describe NewsAsHomeComponent do
  it { should have_setting :page_id }
  it { should have_setting :show_title }
  it { should have_setting :show_info }

  it { should validate_presence_of :page_id }
end
