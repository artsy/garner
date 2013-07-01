module Garner
  module Strategies
    module Context
      module Key
        class RequestGet < Base

          def self.field
            :request_params
          end

          # Injects the request GET parameters into the key hash.
          #
          # @param identity [Garner::Cache::Identity] The cache identity.
          # @param ruby_context [Object] An optional Ruby context.
          # @return [Garner::Cache::Identity] The modified identity.
          def self.apply(identity, ruby_context = nil)
            return identity unless (ruby_context.respond_to?(:request))

            request = ruby_context.request
            if request && ["GET", "HEAD"].include?(request.request_method)
              identity.key(field => request.GET.dup)
            end
            identity
          end

        end
      end
    end
  end
end
