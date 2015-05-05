require 'rails_helper'

describe ComponentsGroupComponent do
  it { should have_setting :html_class }

  it { should allow_value('class').for(:html_class) }
  it { should_not allow_value('<body></bodyx>').for(:html_class) }
end
