require File.join(File.dirname(__FILE__), 'test_helper')

class TestApp
  def call(env)
    response = "Hello, World!"
    ["200", {'Content-Type' => 'text/plain', 'Content-Length' => response.length.to_s}, [response]]
  end
end

class TestApp404
  def call(env)
    response = "Bye, World!"
    ["404", {'Content-Type' => 'text/plain', 'Content-Length' => response.length.to_s}, [response]]
  end
end

class RackDomainsTest < Test::Unit::TestCase
  context "Routing by domain" do
    test "should send the process to the right app" do
      app = Rack::Builder.new do
	use Rack::Lint
	use Rack::Domains, {"app1" => TestApp.new}
	run TestApp404.new
      end
      response = Rack::MockRequest.new(app).get('/', {'SERVER_NAME' => "app1"})
      response.body.should == 'Hello, World!'
      response.status.should == 200

      response = Rack::MockRequest.new(app).get('/', {'SERVER_NAME' => "app2"})
      response.status.should == 404
    end

    test "should match domains with regular expressions" do
      app = Rack::Builder.new do
	use Rack::Lint
	use Rack::Domains do
	  map /^app.*$/, TestApp.new
	end
	run TestApp404.new
      end
      response = Rack::MockRequest.new(app).get('/', {'SERVER_NAME' => "app1"})
      response.body.should == 'Hello, World!'
      response.status.should == 200

      response = Rack::MockRequest.new(app).get('/', {'SERVER_NAME' => "bpp1"})
      response.status.should == 404
    end
  end
end

