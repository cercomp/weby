require 'rails_helper'

describe PhotoSliderComponent do
  it { should have_setting :photo_ids }
  it { should have_setting :width }
  it { should have_setting :height }
  it { should have_setting :timer }
  it { should have_setting :description }
  it { should have_setting :style }
  it { should have_setting :show_controls }
  it { should have_setting :title }

  it { should have_i18n_setting :title }
end
