require 'spec_helper'

describe Page do

  before :each do
    @page = Page.new author_id: 1, date_begin_at: Time.now
    @page.type = 'News'
  end

  subject { Page.new }

  context 'Page#author_id' do
    it { should validate_presence_of(:author_id) }
  end

  context "Page#date_begin_at" do
    it { should validate_presence_of(:date_begin_at) }
    it { should allow_value(Time.now).for(:date_begin_at) }
  end

  context "Internationalizations" do
    it "should have association with page_i18n" do
      subject.should respond_to(:page_i18ns)
    end

    it "should accept page_i18n's attributes" do
      subject.update_attributes page_i18ns_attributes: [
        { title: 'title' } 
      ]
      subject.page_i18ns.should have(1).elements
    end

    it "should reject page_i18n without title or marked to destruction" do
      @page.update_attributes page_i18ns_attributes: [ { title: '' } ]
      @page.page_i18ns.count.should == 0
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

