module Garner
  module Strategies
    module Keys
      module Jsonp
        class << self

          def field
            :request_params
          end

          # Strips JSONP parameters from the key.
          #
          # @param identity [Garner::Cache::Identity] The cache identity.
          # @param ruby_context [Binding] An optional Ruby context.
          # @return [Garner::Cache::Identity] The modified identity.
          def apply(identity, ruby_context = self)
            key_hash = identity.key_hash
            return identity unless key_hash[field]


            key_hash[field].delete("callback")
            key_hash[field].delete("_")
            identity
          end

        end
      end
    end
  end
end
