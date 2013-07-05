module TentD
  module Omnibus
    class AccessControl < Rack::Putty::Middleware
      def action(env)
        env['response.headers'] ||= {}
        env['response.headers'].merge!(
          'Access-Control-Allow-Credentials' => 'true',
          'Access-Control-Allow-Origin' => 'self',
          'Access-Control-Allow-Methods' => 'DELETE, GET, HEAD, PATCH, POST, PUT',
          'Access-Control-Allow-Headers' => 'Cache-Control, Pragma',
          'Access-Control-Max-Age' => '10000'
        )
        env
      end
    end
  end
end
