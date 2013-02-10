require File.join(File.dirname(__FILE__), 'test_helper')

class StringUtilTest < MiniTest::Unit::TestCase
  
  describe "elide" do
    before do
      @util = Rack::Padlock::StringUtil.new
    end
    
    it "should add ellipsis and shorten words" do
      @util.elide("hootinanny", 4).must_equal "ho...ny"
      @util.elide("hootinanny", 10).must_equal "hootinanny"
      @util.elide("hootinanny", 11).must_equal "hootinanny"
      @util.elide("hootinanny", 9).must_equal "hooti...anny"
      @util.elide("hootinanny", 0).must_equal "hootinanny"
    end
  end  
end