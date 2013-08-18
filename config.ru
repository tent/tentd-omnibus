lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler/setup'
require 'tentd-omnibus'

TentD::Omnibus.setup!

TentD::Worker.configure_client

session_cookie_options = {
  :key => 'tentd-omnibus.session',
  :expire_after => 2592000, # 1 month
  :secret => ENV['SESSION_SECRET'] || SecureRandom.hex
}

if ENV['RACK_ENV'] == 'production'
  require 'rack/ssl-enforcer'
  use Rack::SslEnforcer
end

map '/' do
  use Rack::Session::Cookie, session_cookie_options
  run TentD::Omnibus::Shared.new
end

map '/tent/oauth/authorize' do
  run lambda { |env|
    [301, { "Location" => "/admin/oauth?#{env['QUERY_STRING']}" }, []]
  }
end

map '/tent' do
  run TentD::API.new
end

map '/status' do
  use Rack::Session::Cookie, session_cookie_options
  use TentD::Omnibus::Authentication
  run TentD::Omnibus::Status.new
end

map '/admin' do
  use Rack::Session::Cookie, session_cookie_options
  use TentD::Omnibus::Authentication
  run TentD::Omnibus::Admin.new
end
