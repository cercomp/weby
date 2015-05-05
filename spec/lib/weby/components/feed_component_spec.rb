require 'rails_helper'

describe FeedComponent do
  it { should have_setting :rss_icon }
  it { should have_setting :atom_icon }
  it { should have_setting :align }
end
