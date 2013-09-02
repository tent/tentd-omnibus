require 'erb'

module TentD
  module Omnibus
    class RenderView < Rack::Putty::Middleware

      class TemplateContext
        attr_reader :env
        def initialize(env, renderer)
          @env, @renderer = env, renderer
        end

        def erb(view_name)
          @renderer.erb(view_name, binding)
        end

        def flash_error
          env['flash_error']
        end

        def params
          env['params']
        end

        def asset_path(asset_name)
          return unless manifest = Omnibus.settings[:asset_manifest]
          return unless Hash === manifest && Hash === manifest['files']
          compiled_name = manifest['files'].find { |k,v|
            v['logical_path'] == asset_name
          }.to_a[0]

          return unless compiled_name

          "#{TentD::Omnibus.settings[:url]}/assets/#{compiled_name}"
        end

        def csrf_token
          env['rack.session']['_csrf_token']
        end
      end

      def initialize(app, options = {})
        super

        @path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'views', "#{@options[:view]}.erb"))
        @exists = File.exists?(@path)
      end

      def action(env)
        unless @exists
          env['response.status'] = 404
          return env
        end

        env['response.status'] = 200
        env['response.headers'] ||= {}
        env['response.headers'].merge!(
          'Content-Type' => 'text/html'
        )
        env['response.body'] = [render(env)]

        env
      end

      def erb(view_name, binding, &block)
        template = ERB.new(File.read(@path))
        template.result(binding)
      end

      private

      def render(env)
        erb(env['response.view'], template_binding(env))
      end

      def template_binding(env)
        TemplateContext.new(env, self).instance_eval { binding }
      end

    end
  end
end
