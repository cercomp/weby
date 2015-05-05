require 'rails_helper'

describe InstitutionalLinksComponent do
  it { should have_setting :institution }
  it { should have_setting :html_class }
  it { should have_setting :format }
  it { should have_setting :new_tab }

  it { should validate_presence_of :institution }
end
