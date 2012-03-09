require 'spec_helper'

describe Site do

  subject { Site.new }

  it { should have_valid(:name).when('Teste') }
  it { should_not have_valid(:name) }

  it { should have_valid(:url).when('http://localhost.com', 'http://www.teste.com.br') }
  it { should_not have_valid(:url).when(nil, '', 'asdf', 'user@gmail.com', 'localhost.com') }

  it "Site#name should be unique" do
    Site.new.tap do |site|
      2.times { site = Site.create name: 'One', url: 'http://localhost.com' }
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
