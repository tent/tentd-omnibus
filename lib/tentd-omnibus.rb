require 'rack'
require 'tentd'
require 'tentd-omnibus/version'
require 'yajl'

module TentD
  module Omnibus
    extend self

    require 'tentd-omnibus/authentication'

    URLNotSetError = Class.new(StandardError)

    def settings
      @settings ||= {
        :entity => ENV['TENT_ENTITY'] || ENV['URL'] ? "#{ENV['URL'].to_s.sub(%r{/\Z}, '')}/tent" : nil,
        :display_url => ENV['DISPLAY_URL'] || "https://github.com/tent/tentd-omnibus",
        :url => ENV['URL']
      }
    end

    def configure
      settings[:asset_manifest_path] ||= File.expand_path(File.join(File.dirname(__FILE__), '..', 'public', 'assets', 'manifest.json'))
      if File.exists?(settings[:asset_manifest_path])
        settings[:asset_manifest] = Yajl::Parser.parse(File.read(settings[:asset_manifest_path]))
      end

      settings[:status_display_url] = ENV['STATUS_DISPLAY_URL'] || settings[:display_url]
      settings[:admin_display_url]  = ENV['ADMIN_DISPLAY_URL']  || settings[:display_url]
    end

    def setup!(options = {})
      unless settings[:url]
        raise URLNotSetError.new("You need to set ENV['URL']!")
      end

      ENV['TENT_ENTITY'] ||= settings[:entity]

      TentD.setup!(options)

      configure

      require 'tentd-omnibus/tentd/models/user'

      create_user
      setup_status
      setup_admin

      require 'tentd-omnibus/base'
      require 'tentd-omnibus/shared'
      require 'tentd-omnibus/status'
      require 'tentd-omnibus/admin'
    end

    def create_user
      settings[:user] = TentD::Model::User.first_or_create(settings[:entity])
    end

    def setup_status
      require 'tent-status'

      # find or create app / auth
      if settings[:user].status_app_id
        app = TentD::Model::App.where(:id => settings[:user].status_app_id).first
      else
        app_post, app = create_app(
          :name => 'Status',
          :display_url => settings[:status_display_url],
          :read_types => TentStatus.settings[:read_types],
          :write_types => TentStatus.settings[:write_types],
          :scopes => TentStatus.settings[:scopes]
        )

        auth_post = create_auth(app_post)

        settings[:user].update(:status_app_id => app.id)
        app.reload
      end

      auth_credentials_post = TentD::Model::Post.where(:id => app.auth_credentials_post_id).first
      app_post ||= TentD::Model::Post.where(:id => app.post_id).first

      settings[:status_config] = config_json(app_post, auth_credentials_post)
    end

    def setup_admin
      require 'tent-admin'

      # find or create app /auth
      if settings[:user].admin_app_id
        app = TentD::Model::App.where(:id => settings[:user].admin_app_id).first
      else
        app_post, app = create_app(
          :name => 'Admin',
          :display_url => settings[:admin_display_url],
          :read_types => TentAdmin.settings[:read_types],
          :write_types => TentAdmin.settings[:write_types],
          :scopes => TentAdmin.settings[:scopes]
        )

        auth_post = create_auth(app_post)

        settings[:user].update(:admin_app_id => app.id)
        app.reload
      end

      auth_credentials_post = TentD::Model::Post.where(:id => app.auth_credentials_post_id).first
      app_post ||= TentD::Model::Post.where(:id => app.post_id).first

      settings[:admin_config] = config_json(app_post, auth_credentials_post).merge(
        :protected_apps => [app_post.public_id, status_app_post.public_id]
      )
    end

    def status_app_post
      app = TentD::Model::App.where(:id => settings[:user].status_app_id).first
      TentD::Model::Post.where(:id => app.post_id).first
    end

    def config_json(app_post, auth_credentials_post)
      {
        :credentials => TentD::Model::Credentials.slice_credentials(auth_credentials_post),
        :meta => settings[:user].meta_post.as_json,
        :app => {
          :id => app_post.public_id
        }
      }
    end

    def create_app(options = {})
      app_post = TentD::Model::PostBuilder.create_from_env(
        'current_user' => settings[:user],
        'data' => {
          'entity' => settings[:entity],
          'type' => 'https://tent.io/types/app/v0#',
          'content' => {
            'name' => options[:name],
            'url' => options[:display_url],
            'redirect_uri' => settings[:url],
            'types' => {
              'read' => options[:read_types],
              'write' => options[:write_types],
            },
            'scopes' => options[:scopes].to_a
          }
        }
      )
      app = TentD::Model::App.update_or_create_from_post(app_post, :create_credentials => true)
      [app_post, app]
    end

    def create_auth(app_post)
      auth_post = TentD::Model::AppAuth.create(
        settings[:user],
        app_post,
        app_post.content['types'],
        app_post.content['scopes']
      )
    end
  end
end
