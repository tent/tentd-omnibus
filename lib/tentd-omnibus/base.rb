module TentD
  module Omnibus
    class Base

      require 'tentd-omnibus/base/serialize_response'
      require 'tentd-omnibus/base/render_static'
      require 'tentd-omnibus/base/access_control'
      require 'tentd-omnibus/base/cache_control'
      require 'tentd-omnibus/base/config_json'
      require 'tentd-omnibus/base/asset_server'
      require 'tentd-omnibus/base/content_security_policy'

    end
  end
end
