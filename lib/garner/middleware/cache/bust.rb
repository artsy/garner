module Garner
  module Middleware
    module Cache
      class Bust < Garner::Middleware::Base
        def after
          # private: ok to store API results in a private cache
          # max-age: don't reuse the cached result without checking with the server (server might say 304 Not Modified)
          # must-revalidate: prevent gateways from returning a response if the API server is not reachable
          @app_response[1]["Cache-Control"] = "private, max-age=0, must-revalidate"
          # don't reuse the cached result without checking with the server
          @app_response[1]["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
          @app_response
        end
      end
    end
  end
end

