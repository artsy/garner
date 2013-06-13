module Garner
  module Strategies
    module Binding
      module Key
        class SafeCacheKey < Base

          # Compute a cache key from an object binding.
          #
          # @param binding [Object] The object from which to compute a key.
          # @return [String] A cache key string.
          def apply(binding)
            if binding.respond_to?(:safe_cache_key)
              binding.safe_cache_key
            elsif binding.respond_to?(:cache_key)
              binding.cache_key
            end
          end

        end
      end
    end
  end
end
