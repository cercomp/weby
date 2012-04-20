require 'spec_helper'

describe "pages/new" do
  before(:each) do
    assign(:page, stub_model(Page).as_new_record)
  end

  it "renders new page form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => pages_path, :method => "post" do
    end
  end
end
