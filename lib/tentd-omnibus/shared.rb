module TentD
  module Omnibus
    class Shared
      include Rack::Putty::Router

      require 'tentd-omnibus/base/serialize_response'
      stack_base SerializeResponse

      require 'tentd-omnibus/base/render_view'

      class Signout < Rack::Putty::Middleware
        def action(env)
          env['rack.session'].delete('authenticated')
          env['response.status'] = 200
          env
        end
      end

      class ExtractFormData < Rack::Putty::Middleware
        def action(env)
          data = env['rack.input'].read.to_s.split('&').inject({}) { |m, i| k,v = i.split('='); m[k.to_sym] = v; m }
          env['rack.input'].rewind
          env['data'] = data
          env
        end
      end

      class GenerateCSRF < Rack::Putty::Middleware
        require 'securerandom'

        def action(env)
          env['rack.session']['_csrf_token'] = SecureRandom.hex
          env
        end
      end

      class VerifyCSRF < Rack::Putty::Middleware
        def action(env)
          token = env['rack.session']['_csrf_token']
          unless token == env['data'][:_csrf]
            return [400, {}, []]
          end

          env
        end
      end

      class Signin < Rack::Putty::Middleware
        require 'bcrypt'

        def action(env)
          params = env['data']

          if authenticate(params[:username], params[:passphrase])
            env['rack.session']['authenticated'] = true

            return [301, { 'Location' => env['rack.session']['redirect_url'] || TentD::Omnibus.settings[:url] }, []]
          else
            env['rack.session']['authenticated'] = false
            env['flash_error'] = "Incorrect username or passphrase"
          end

          env
        end

        private

        def authenticate(username, passphrase)
          BCrypt::Password.new(ENV['PASSPHRASE']) == passphrase && username == ENV['USERNAME']
        end
      end

      class Redirect < Rack::Putty::Middleware
        def action(env)
          [302, { "Location" => "#{TentD::Omnibus.settings[:url]}/#{@options[:app]}" }, []]
        end
      end

      get '/assets/*' do |b|
        b.use AssetServer
      end

      post '/signout' do |b|
        b.use Signout
      end

      get '/signin' do |b|
        b.use GenerateCSRF
        b.use RenderView, :view => :signin
      end

      post '/signin' do |b|
        b.use ExtractFormData
        b.use VerifyCSRF
        b.use Signin
        b.use RenderView, :view => :signin
      end

      match '/' do |b|
        b.use Redirect, :app => :status
      end

      get '*' do |b|
      end
    end
  end
end
