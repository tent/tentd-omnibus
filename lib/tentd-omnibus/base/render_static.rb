module TentD
  module Omnibus
    class RenderStatic < Rack::Putty::Middleware

      def self.static_path(view)
        # public/{view}.html
        File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'public', "#{view}.html"))
      end

      def initialize(app, options = {})
        super

        @path = self.class.static_path(@options[:view])
        @exists = File.exists?(@path)

        if @exists
          @response = [ 200, { 'Content-Type' => 'text/html' }, [File.read(@path)] ]
        end
      end

      def action(env)
        return env unless @exists

        status, headers, body = @response

        env['response.status'] = status
        env['response.headers'] ||= {}
        env['response.headers'].merge!(headers)
        env['response.body'] = body

        env
      end

    end
  end
end
