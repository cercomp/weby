require 'spec_helper'

describe Site do

  subject { Site.new }

  context "#name" do
    it { should validate_presence_of(:name) }
    it { should allow_value('Teste').for(:name) }

    it "should be unique" do
      Site.new.tap do |site|
        2.times { site = Site.create name: 'One', url: 'http://localhost.com' }
        site.should have_at_least(1).error_on(:name)
      end
    end
  end

  context "#per_page" do
    it "should have default value" do
      subject.per_page.should == Site.columns_hash['per_page'].default
    end
    it "should be a number's list separated by commas" do
      subject.per_page.should match /([0-9]+[,\s]*)+[0-9]*/
    end
  end

  context "#url" do
    ['http://localhost.com', 'http://www.teste.com.br'].each do |value|
      it { should allow_value(value).for(:url) }
    end

    [nil, '', 'asdf', 'user@gmail.com', 'localhost.com'].each do |value|
      it { should_not allow_value(value).for(:url) }
    end
  end

  context "#styles" do
    it "may have many relations with the table sites_styles " do
      subject.should have_many(:sites_styles)
    end

    it "may follow many styles" do
      subject.should have_many(:follow_styles).through(:sites_styles)
    end

    it "may have many own styles" do
      subject.should have_many(:own_styles)
    end
  end

  context "#pages" do
    it "may have many pages" do
      subject.should have_many(:pages)
    end
  end
end
