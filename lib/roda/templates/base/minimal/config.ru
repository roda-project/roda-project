require_relative 'boot'
# Rack::Attack.throttle('signup/ip', limit: 3, period: 15.minutes) do |req|
# req.ip if req.path == '/signup'
# end

if NOT_PRODUCTION
  require "rack-livereload"
  require "guard/livereload"
  use Rack::LiveReload
end

use Rack::Static, urls: ["/public"]
run App
