require 'spec_helper'

class Validable
  include ActiveModel::Validations
  validates_with WebyI18nContentValidator 

  attr_accessor :i18ns

  def initialize
    @i18ns = []
  end
end

class FakeI18n
  include ActiveModel::Validations 
  validates :locale, presence: true

  attr_accessor :locale

  def marked_for_destruction?
    false 
  end
end

describe WebyI18nContentValidator do
  before(:each) do
    @i18n = FakeI18n.new
    subject.i18ns.clear
  end

  subject { Validable.new }

  it { should respond_to(:i18ns) }

  it "should not be valid without i18ns" do
    subject.should_not be_valid
  end

  it "should not be valid with invalid i18n" do
    subject.i18ns << @i18n
    subject.should_not be_valid
  end

  it "should be valid with an i18n" do
    @i18n.locale = 'en'
    subject.i18ns << @i18n
    subject.should be_valid
  end

  it "should not be valid with i18ns with same locale" do
    @i18n.locale = 'en'
    2.times {
      subject.i18ns << @i18n
    }
    subject.should_not be_valid
  end
end
