module TentD
  module Omnibus
    class Admin
      include Rack::Putty::Router

      require 'tentd-omnibus/base/serialize_response'
      stack_base SerializeResponse

      require 'tentd-omnibus/base/render_static'
      require 'tentd-omnibus/base/config_json'

      get '/config.json' do |b|
        b.use ContentSecurityPolicy
        b.use AccessControl
        b.use CacheControl
        b.use ConfigJson, :app_name => :admin
      end

      get '*' do |b|
        b.use ContentSecurityPolicy
        b.use RenderStatic, :view => :admin
      end

    end
  end
end
