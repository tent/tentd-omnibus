require 'rack-putty'

module TentD
  module Omnibus
    class Authentication < Rack::Putty::Middleware

      def action(env)
        if env['rack.session']['authenticated'] == true
          env['authenticated'] = true
        else
          env['authenticated'] = false
          env['rack.session']['redirect_url'] = env['REQUEST_URI']
          return [302, { "Location" => "#{TentD::Omnibus.settings[:url]}/signin" }, []]
        end

        env
      end

    end
  end
end
