# encoding: binary
require_relative "spec_helper"

describe "Decimal rounding" do
  it "should round floating point numbers to four decimal places" do
    PDF::Core.real(1.23456789).should == 1.2346
  end

  it "should be able to create a PDF parameter list of rounded decimals" do
    PDF::Core.real_params([1,2.34567,Math::PI]).should == "1.0 2.3457 3.1416"
  end
end
