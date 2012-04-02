require 'spec_helper'

describe Page do
  before :each do
    @locale = Factory(:locale)
    @page = Factory.build(:page, type: 'News')
  end

  it { should validate_presence_of(:type) }
  it { should allow_value('News').for(:type) }
  it { should allow_value('Event').for(:type) }
  it { should_not allow_value('Page').for(:type) }

  it { should belong_to(:author) }
  it { should validate_presence_of(:author_id) }

  it { should belong_to(:owner) }
  it { should validate_presence_of(:site_id) }

  it { should validate_presence_of(:date_begin_at) }
  it { should allow_value(Time.now).for(:date_begin_at) }

  context 'Event' do
    [nil, '', 'international', 'national', 'regional'].each do |value|
      it { should allow_value(value).for(:kind) }
    end
    it { should_not allow_value('other').for(:kind) }

    it "should require local(only if page is an event)" do
      @page.type = 'Event' 
      @page.should_not be_valid
      @page.should have_at_least(1).error_on(:local)
    end
  end

  context "Image" do
    it "may have one image" do
      should belong_to(:image)
    end
    it "should accept only its own images" do
      @page.image = Factory(:image_repository, site: Factory(:site))
      @page.valid?
      @page.errors.should include(:image)
    end
    it "should accept only images" do
      @page.image = Factory(:image_repository, site: @page.owner)
      @page.valid?
      @page.errors.should_not include(:image)
      @page.image = Factory(:pdf_repository)
      @page.valid?
      @page.should have_at_least(1).error_on(:image)
    end
  end

  context "Related Files" do
    it "may have many related files" do
      should have_many(:related_files) 
    end
    it "should accept only its own files" do
      @page.update_attributes related_files: [
        Factory(:image_repository, site: Factory(:site)),
        Factory(:pdf_repository, site: Factory(:site)),
      ]
      @page.valid?
      @page.should have_at_least(1).error_on(:related_files)
    end
  end

  context "i18ns" do
    it "may have many i18ns" do
      @page.should have_many(:i18ns)
    end

    it "should validates with Weby i18n content validator" do
      Page.validators.map(&:class).should include(WebyI18nContentValidator)
    end

    it "should have at least one page_i18n" do
      @page.should_not be_valid
      @page.should have_at_least(1).error_on(:base)
    end

    it "should accept i18ns attributes" do
      @page.update_attributes i18ns_attributes: [
        { title: 'title', locale: @locale } 
      ]
      @page.i18ns.count.should == 1
    end

    it "should reject i18n without title" do
      @page.update_attributes i18ns_attributes: [ { title: '', locale: @locale } ]
      @page.i18ns.count.should == 0
    end
  end

end

