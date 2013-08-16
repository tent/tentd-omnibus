require 'yajl'

module TentD
  module Omnibus
    class ConfigJson < Rack::Putty::Middleware

      ConfigNotFoundError = Class.new(StandardError)

      def initialize(app, options = {})
        super

        key = :"#{@options[:app_name]}_config"
        @config = TentD::Omnibus.settings[key]

        unless @config
          raise ConfigNotFoundError.new("Config for #{@options[:app_name]} is not set")
        end
      end

      def config_json
        Yajl::Encoder.encode(@config.call)
      end

      def action(env)
        if env['authenticated'] == true
          env['response.status'] = 200
          env['response.headers'] ||= {}
          env['response.headers'].merge!(
            'Content-Type' => 'application/json'
          )
          env['response.body'] = config_json
        else
          env['response.status'] = 404
        end

        env
      end

    end
  end
end
