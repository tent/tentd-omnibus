lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler/setup'
require 'tentd-omnibus'

##
# Boot Sidekiq

if ENV['RUN_SIDEKIQ'] != 'false'
  sidekiq_pid = fork do
    exec(*%w(bundle exec sidekiq -r ./sidekiq.rb))
  end

  at_exit do
    puts "Killing sidekiq server (pid: #{sidekiq_pid})"
    Process.kill("INT", sidekiq_pid)
  end
else
  sidekiq_pid = nil
end

##
# Boot Unicorn

unicorn_pid = fork do
  exec("bundle", "exec", "unicorn", "-p", ENV['PORT'] || "8080", "-c", "./config/unicorn.rb")
end

at_exit do
  puts "Killing unicorn (pid: #{unicorn_pid})"
  Process.kill("QUIT", unicorn_pid)
end

Process.wait(unicorn_pid) rescue nil
Process.wait(sidekiq_pid) rescue nil

