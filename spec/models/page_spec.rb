require 'spec_helper'

describe Page do

  before :each do
    @page = Page.new author_id: 1, date_begin_at: Time.now
    @page.type = 'News'
  end

  subject { Page.new }

  it { should belong_to(:author) }
  it { should validate_presence_of(:author_id) }

  it { should belong_to(:site) }
  it { should validate_presence_of(:site_id) }

  it { should validate_presence_of(:date_begin_at) }
  it { should allow_value(Time.now).for(:date_begin_at) }
  [nil, '', 'asdf'].each do |value|
    it { should_not allow_value(value).for(:date_begin_at) }
  end


  context "i18ns" do
    it { should has_many(:i18ns) }

    it "should accept i18ns attributes" do
      subject.update_attributes i18ns_attributes: [
        { title: 'title' } 
      ]
      subject.i18ns.should have(1).elements
    end

    it "should reject page_i18n without title or marked to destruction" do
      @page.update_attributes i18ns_attributes: [ { title: '' } ]
      @page.i18ns.count.should == 0
    end

    it "should have at least one page_i18n" do
      @page.should_not be_valid
      @page.should have_at_least(1).error_on(:base)
      @page.update_attributes page_i18ns_attributes: [
        { title: 'title' },
        { title: 'title1' },
        { title: '' }
      ]
      @page.page_i18ns.count.should == 2
    end
  end

end

