require 'bundler/setup'
require 'bundler/gem_tasks'
require 'tentd/tasks/db'

require 'memcachier'
if ENV['MEMCACHE_SERVERS']
  require 'sprockets_memcached'
end

def configure_tent_status
  return if @tent_status_configured
  @tent_status_configured = true

  require 'tent-status/compiler'

  public_dir = File.expand_path(File.join(File.dirname(__FILE__), 'public'))
  TentStatus::Compiler.assets_dir = File.join(public_dir, 'assets')
  TentStatus::Compiler.layout_dir = public_dir
  TentStatus::Compiler.layout_path = File.join(TentStatus::Compiler.layout_dir, 'status.html')

  TentStatus::Compiler.compile_icing = true
  TentStatus::Compiler.compile_marbles = true

  TentStatus::Compiler.configure_app(
    :url => "#{ENV['URL']}/status",
    :path_prefix => '/status',
    :asset_root => '/assets',
    :json_config_url => "#{ENV['URL']}/status/config.json",
    :admin_url => "/admin",
    :signout_url => "/signout"
  )

  TentStatus::Compiler.configure_sprockets

  if defined?(Sprockets::Cache::MemcacheStore)
    TentStatus::Compiler.sprockets_environment.cache = Sprockets::Cache::MemcacheStore.new
  else
    TentStatus::Compiler.sprockets_environment.cache = Sprockets::Cache::FileStore.new("./.tmp")
  end
end

def configure_tent_admin
  return if @tent_admin_configured
  @tent_admin_configured = true

  require 'tent-status'
  require 'tent-admin/compiler'

  public_dir = File.expand_path(File.join(File.dirname(__FILE__), 'public'))
  TentAdmin::Compiler.assets_dir = File.join(public_dir, 'assets')
  TentAdmin::Compiler.layout_dir = public_dir
  TentAdmin::Compiler.layout_path = File.join(TentAdmin::Compiler.layout_dir, 'admin.html')

  TentAdmin::Compiler.compile_icing = true
  TentAdmin::Compiler.compile_marbles = true

  TentAdmin::Compiler.configure_app(
    :url => "#{ENV['URL']}/admin",
    :path_prefix => '/admin',
    :asset_root => '/assets',
    :json_config_url => "#{ENV['URL']}/admin/config.json",
    :status_url => "/status",
    :search_url => TentStatus.settings[:search_enabled] ? "/status/search" : nil,
    :signout_url => "/signout"
  )

  TentAdmin::Compiler.configure_sprockets

  if defined?(Sprockets::Cache::MemcacheStore)
    TentAdmin::Compiler.sprockets_environment.cache = Sprockets::Cache::MemcacheStore.new
  else
    TentAdmin::Compiler.sprockets_environment.cache = Sprockets::Cache::FileStore.new("./.tmp")
  end
end

namespace :status do
  task :compile do
    configure_tent_status
    TentStatus::Compiler.gzip_assets
    TentStatus::Compiler.gzip_layout
  end
end

namespace :admin do
  task :compile do
    configure_tent_admin

    TentAdmin::Compiler.gzip_assets
    TentAdmin::Compiler.gzip_layout
  end
end

namespace :assets do
  desc "Precompile Status and Admin apps"
  task :precompile => [ "admin:compile", "status:compile" ] do
  end
end

task :encrypt_passphrase, :passphrase do |t, args|
  require 'bcrypt'
  puts BCrypt::Password.create(args[:passphrase])
end
