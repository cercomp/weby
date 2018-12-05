describe 'Dirge' do
  before do
    @dir = 'test2test'
  end
  it "should resolve a path through String#~" do
    (~"#{@dir}/test").should == File.expand_path(File.join(File.dirname(__FILE__), @dir, 'test'))
  end
  
  it "should resolve a path through File#relative" do
    File.relative("#{@dir}/test").should == File.expand_path(File.join(File.dirname(__FILE__), @dir, 'test'))
  end
  
  it 'should require a relative path' do
    proc {
      require_relative "#{@dir}/test"
    }.should raise_error(RuntimeError, 'okay okay, you included me')
  end
  
  it 'should autoload a relative path' do
    dir = @dir
    proc {
      mod = Module.new do
        autoload_relative :TestingTime, "#{dir}/test"
      end
      mod::TestingTime
    }.should raise_error(RuntimeError, 'okay okay, you included me')
  end
  
  it "should define __DIR__" do
    __DIR__.should == File.expand_path(File.dirname(__FILE__))
  end
  
  it "should define __DIR__ with a custom caller" do
    __DIR__('testing/test.rb:3').should == File.expand_path('testing')
  end
  
end