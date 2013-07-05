module TentD
  module Omnibus
    class CacheControl < Rack::Putty::Middleware
      def action(env)
        env['response.headers'] ||= {}
        env['response.headers'].merge!(
          'Cache-Control' => cache_control(env),
          'Vary' => 'Cookie'
        )
        env
      end

      private

      def cache_control(env)
        if env['authenticated'] == true
          'private, max-age=600'
        else
          'no-cache'
        end
      end
    end
  end
end
