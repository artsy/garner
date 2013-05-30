module Garner
  module Strategies
    module ContextKey
      module RequestPath
        class << self

          def field
            :request_path
          end

          # Injects the request path into the key hash.
          #
          # @param identity [Garner::Cache::Identity] The cache identity.
          # @param ruby_context [Binding] An optional Ruby context.
          # @return [Garner::Cache::Identity] The modified identity.
          def apply(identity, ruby_context = self)
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
