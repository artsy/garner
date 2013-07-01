module Garner
  module Strategies
    module Context
      module Key
        class RequestPath < Base

          def self.field
            :request_path
          end

          # Injects the request path into the key hash.
          #
          # @param identity [Garner::Cache::Identity] The cache identity.
          # @param ruby_context [Object] An optional Ruby context.
          # @return [Garner::Cache::Identity] The modified identity.
          def self.apply(identity, ruby_context = nil)
            return identity unless (ruby_context.respond_to?(:request))

            request = ruby_context.request
            identity.key(field => request.path) if request.respond_to?(:path)
            identity
          end

        end
      end
    end
  end
end
