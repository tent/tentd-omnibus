lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler/setup'
require 'tentd-omnibus'

if ENV['RUN_SIDEKIQ'] != 'false'
  # run sidekiq server
  require 'tentd/worker'
  sidekiq_pid = TentD::Worker.run_server

  puts "Sidekiq server running (pid: #{sidekiq_pid})"
else
  sidekiq_pid = nil
end

TentD::Omnibus.setup!

TentD::Worker.configure_client

session_cookie_options = {
  :key => 'tentd-omnibus.session',
  :expire_after => 2592000, # 1 month
  :secret => ENV['SESSION_SECRET'] || SecureRandom.hex
}

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

if sidekiq_pid
  at_exit do
    puts "Killing sidekiq server (pid: #{sidekiq_pid})..."
    Process.kill("INT", sidekiq_pid)
  end
end
