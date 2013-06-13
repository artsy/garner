module Garner
  module Strategies
    module Binding
      module Key
        class Base

          # Compute a cache key from an object binding.
          #
          # @param binding [Object] The object from which to compute a key.
          # @return [String] A cache key string.
          def self.apply(binding)
            nil
          end

        end
      end
    end
  end
end
