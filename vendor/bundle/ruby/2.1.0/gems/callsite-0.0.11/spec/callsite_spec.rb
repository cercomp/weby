describe 'Callsite' do

  it "should parse dir:name/file:name:12" do
    @parsed = Callsite.parse('dir:name/file:name:12')
    @parsed.filename.should == 'dir:name/file:name'
    @parsed.line.should == 12
    @parsed.method.should == nil
  end

  it "should parse dir:name/file:name:12:in `something'" do
    @parsed = Callsite.parse("dir:name/file:name:12:in `something'")
    @parsed.filename.should == 'dir:name/file:name'
    @parsed.line.should == 12
    @parsed.method.should == 'something'
  end

  it "should parse dir:name/file:name:12:in `something more like this'" do
    @parsed = Callsite.parse("dir:name/file:name:12:in `something more like this'")
    @parsed.filename.should == 'dir:name/file:name'
    @parsed.line.should == 12
    @parsed.method.should == 'something more like this'
  end
end