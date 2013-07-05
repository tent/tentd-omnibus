module TentD
  module Omnibus

    module SerializeResponse
      extend self

      NOT_FOUND_RESPONSE = [404, { 'Content-Type' => 'text/plain' }, ["Not Found"]]

      def call(env)
        if env['response.status'] || env['response.headers'] || env['response.body']
          status = env['response.status'] || 200
          headers = env['response.headers'] || {}

          if env['response.body']
            if env['response.body'].respond_to?(:each)
              body = env['response.body']
            else
              body = [env['response.body']]
            end
          else
            body = []
          end

          [status, headers, body]
        else
          NOT_FOUND_RESPONSE
        end
      end
    end

  end
end
