module TentD
  module Omnibus
    class RenderStatic < Rack::Putty::Middleware

      def initialize(app, options = {})
        super

        # public/{view}.html
        @path = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'public', "#{@options[:view]}.html"))
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
