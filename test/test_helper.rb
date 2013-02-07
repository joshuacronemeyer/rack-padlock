require 'minitest/autorun'
require 'rack/mock'
require 'rack/test'
require 'rack/padlock'

class MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app; Rack::Lint.new(@app); end

  def mock_app(options = {})
    main_app = lambda { |env|
      request = Rack::Request.new(env)
      headers = {'Content-Type' => "text/html"}
      [200, headers, ['Hello world!']]
    }

    builder = Rack::Builder.new
    builder.use Rack::Padlock, options
    builder.run main_app
    @app = builder.to_app
  end

end