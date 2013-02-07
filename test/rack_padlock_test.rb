require File.join(File.dirname(__FILE__), 'test_helper')

class RackPadlockTest < MiniTest::Unit::TestCase
  
  describe "Padlock middleware headers" do
    before do
      mock_app
    end
    
    it "sets CSP report only" do
      get 'http://oregonhero.com/wagons/1'
      last_response.headers['Content-Security-Policy-Report-Only'].wont_be_nil
      last_response.headers['X-Content-Security-Policy-Report-Only'].wont_be_nil
      last_response.headers['X-WebKit-CSP-Report-Only'].wont_be_nil
    end
    
    it "sets the report-uri to a value that will be intercepted by padlock middleware" do
      get 'http://oregonhero.com/wagons/1', {}, 'HTTP_HOST' => "http://oregonhero.com"
      last_response.headers['Content-Security-Policy-Report-Only'].must_match "http://oregonhero.com/padlock_middleware/report"
    end
  end
  
  describe "Padlock captures policy violation reports" do
    before do
      mock_app
    end
    
    it "prevents the policy violations from going to the app" do
      post 'http://oregonhero.com/padlock_middleware/report' do 
        "Knock, Knock" 
      end
      last_response.status.must_equal 200
      last_response.body.must_equal ""
    end
    
    it "doesn't interfere with other traffic" do
      get 'http://oregonhero.com/wagons/1'
      last_response.body.must_equal "Hello world!"
    end
    
    # TODO figure out how to set the post data so we can test we log it.
    # it "logs policy violations to padlock logfile" do
    #       post 'http://oregonhero.com/padlock_middleware/report', {}, {"RAW_POST_DATA" => "Knock"}
    #       last_response.status.must_equal 200
    #       last_response.body.must_equal ""
    #       Rack::Padlock::PadlockFile.last_output.must_match /Knock/
    #     end
  end
  
  class Rack::Padlock::PadlockFile
    @@last_output = ""
    def self.write(file, data)
      @@last_output = data
    end
    
    def self.last_output
      @@last_output
    end
    
    def self.last_output=(data)
      @@last_output = data
    end
  end
  
  class DummyApp
    def call(env)
      return [{}, {}, {}]
    end
  end
end