module Garner
  module Strategies
    module Keys
      module RequestPost
        class << self

          def field
            :request_params
          end

          # Injects the request POST parameters into the key hash.
          #
          # @param identity [Garner::Cache::Identity] The cache identity.
          # @param ruby_context [Binding] An optional Ruby context.
          # @return [Garner::Cache::Identity] The modified identity.
          def apply(identity, ruby_context = Kernel.binding)
            return identity unless (ruby_context.respond_to?(:request))

            request = ruby_context.request
            if request.request_method == "POST"
              identity = identity.key(field => request.POST.dup)
            end
            identity
          end

        end
      end
    end
  end
end
