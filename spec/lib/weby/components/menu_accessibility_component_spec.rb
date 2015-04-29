require 'rails_helper'

describe MenuAccessibilityComponent do
  it { should have_setting :font_size }
  it { should have_setting :contrast }
  it { should have_setting :label_contrast }
  it { should have_setting :label_font_size }
  it { should have_setting :extended_accessibility }
  it { should have_setting :additional_information }

  it { should have_i18n_setting :label_contrast }
  it { should have_i18n_setting :label_font_size }
  it { should have_i18n_setting :additional_information }
end
