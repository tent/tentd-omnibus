require 'mimetype_fu'

module TentD
  module Omnibus
    class AssetServer < Rack::Putty::Middleware
      DEFAULT_MIME = 'application/octet-stream'.freeze

      def initialize(app, options = {})
        super

        gem_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))
        @assets_dir = File.join(gem_dir, 'public', 'assets')
      end

      def action(env)
        asset_name = env['params'][:splat]
        compiled_path = File.join(@assets_dir, asset_name)

        if File.exists?(compiled_path)
          env['response.status'] = 200
          env['response.headers'] ||= {}
          env['response.headers'].merge!(
            'Content-Type' => asset_mime_type(asset_name)
          )
          env['response.body'] = [File.read(compiled_path)]
        end

        env
      end

      private

      def asset_mime_type(asset_name)
        mime = File.mime_type?(asset_name)
        mime == 'unknown/unknown' ? DEFAULT_MIME : mime
      end
    end
  end
end
