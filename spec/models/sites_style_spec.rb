require 'spec_helper'

describe SitesStyle do

  it "should belong a site" do
    subject.should belong_to(:site)
    subject.should validate_presence_of(:site_id)
    subject.should validate_numericality_of(:site_id)
  end

  it "should belong a style" do
    subject.should belong_to(:style)
    subject.should validate_presence_of(:style_id)
    subject.should validate_numericality_of(:style_id)
  end

end
