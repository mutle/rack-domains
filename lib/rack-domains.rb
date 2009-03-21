module Rack
  class Domains
    def initialize(app, opts={}, &block)
      @app = app
      @opts = opts
      if block
	instance_eval(&block)
      end
    end

    def map(domain, app)
      @opts[domain] = app
    end

    def call(env)
      @opts.each do |domain, app|
	if (domain.instance_of?(String) && domain == env["SERVER_NAME"]) || (domain.instance_of?(Regexp) && domain.match(env["SERVER_NAME"]))
	  return app.call(env)
	end
      end
      if @app
	@app.call(env)
      else
	response = "Not found"
	["404", {'Content-Type' => 'text/plain', 'Content-Length' => response.length.to_s}, [response]]
      end
    end
  end
end
