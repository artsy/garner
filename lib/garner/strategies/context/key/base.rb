module Garner
  module Strategies
    module Context
      module Key
        class Base

          # Compute a hash of key-value pairs from a given ruby context,
          # and apply it to a cache identity.
          #
          # @param identity [Garner::Cache::Identity] The cache identity.
          # @param ruby_context [Object] An optional Ruby context.
          # @return [Garner::Cache::Identity] The modified identity.
          def self.apply(identity, ruby_context = nil)
            identity
          end

        end
      end
    end
  end
end
