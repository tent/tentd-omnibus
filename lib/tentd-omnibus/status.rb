module TentD
  module Omnibus
    class Status
      include Rack::Putty::Router

      require 'tentd-omnibus/base/serialize_response'
      stack_base SerializeResponse

      require 'tentd-omnibus/base/render_static'
      require 'tentd-omnibus/base/config_json'

      get '/config.json' do |b|
        b.use ContentSecurityPolicy
        b.use AccessControl
        b.use CacheControl, :cache_control => 'no-cache'
        b.use ConfigJson, :app_name => :status
      end

      get '*' do |b|
        b.use ContentSecurityPolicy
        b.use RenderStatic, :view => :status
      end

    end
  end
end
