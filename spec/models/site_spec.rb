require 'spec_helper'

describe Site do

  subject { Site.new }

  %w{name url}.each do |attribute|
    it "not be valid without #{attribute}" do
      subject.should have_at_least(1).error_on(attribute)
    end
  end

  it "Site#name should be unique" do
    Site.new.tap do |site|
      2.times { site = Site.create name: 'One', url: 'http://localhost' }
      site.should have_at_least(1).error_on(:name)
    end
  end

  describe "Per page" do
    it "should have default value" do
      subject.per_page.should == Site.columns_hash['per_page'].default
    end
    it "should be a number's list separated by commas" do
      subject.per_page.should match /([0-9]+[,\s]*)+[0-9]*/
    end
  end
end
