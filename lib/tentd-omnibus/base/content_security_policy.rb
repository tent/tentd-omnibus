module TentD
  module Omnibus
    class ContentSecurityPolicy < Rack::Putty::Middleware
      def initialize(app, options = {})
        super

        security_policy = {
          "default-src" => "'self'",
          "object-src" => "'none'",
          "img-src" => " *",
          "connect-src" => " *"
        }.merge(@options[:directives] || {})

        @security_policy = security_policy.inject([]) { |m, (k,v)| m << "#{k} #{v}"; m }.join('; ')
      end

      def action(env)
        env['response.headers'] ||= {}
        env['response.headers'].merge!(
          "Content-Security-Policy" => @security_policy
        )
        env
      end
    end
  end
end
