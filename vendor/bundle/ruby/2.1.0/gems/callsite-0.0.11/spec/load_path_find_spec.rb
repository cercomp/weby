require 'load_path_find'

$: << File.expand_path(File.join(File.dirname(__FILE__), 'data', 'dir1'))
$: << File.expand_path(File.join(File.dirname(__FILE__), 'data', 'dir2'))

describe 'load path find' do
  it "should find a file on the load path" do
    target = File.join('file1')
    $:.find_file(target)[-target.size, target.size].should == target
  end

  it "should find a directory on the load path" do
    target = "data/dir1"
    $:.find_file("../dir1")[-target.size, target.size].should == target
  end

  it "should find the first file when its ambigious" do
    target = File.join('file1')
    expected_target = File.join('dir1', 'file1')
    $:.find_file(target)[-expected_target.size, expected_target.size].should == expected_target
  end

  it "should find all files that match" do
    target = File.join('file1')
    expected_target = File.join('dir1', 'file1')
    $:.find_all_files(target).should == [
      File.expand_path(File.join(File.dirname(__FILE__), 'data', 'dir1', 'file1')),      
      File.expand_path(File.join(File.dirname(__FILE__), 'data', 'dir2', 'file1'))
    ]
  end

  it "should yield all files that match if a block is given" do
    target = File.join('file1')
    mock = Object.new
    mock.should_receive(:hello).exactly(2).times
    $:.find_all_files(target) { mock.hello }
  end
  
  it "should add the current path" do
    $LOAD_PATH.add_current
    $LOAD_PATH.should include(__DIR__)
  end

  it "should add the current path to the start" do
    $LOAD_PATH.add_current!
    $LOAD_PATH.first.should == __DIR__
  end

  it "should require_all" do
    $state1.should be_nil
    $state2.should be_nil
    require_all('test')
    $state1.should be_true
    $state2.should be_true
  end
  
  it "should require_next" do
    require 'test2'
    $test2.should == 2
  end

end