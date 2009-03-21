A domain-based router for Rack

Usage
  
 use Rack::Domains do
   map /^.*\.example\.com$/, MainApp.new
   map "example.com", LandingPageApp.new
 end 
