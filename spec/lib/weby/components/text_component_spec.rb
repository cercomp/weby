require 'rails_helper'

describe TextComponent do
  it { should have_setting :body }
  it { should have_setting :html_class }

  it { should have_i18n_setting :body }

  it { should allow_value('class').for(:html_class) }
  it { should_not allow_value('<body></bodyx>').for(:html_class) }
end
