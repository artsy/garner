module Garner
  module Strategies
    module Binding
      module Invalidation
        module Touch

          class << self
            # Invalidate an object binding.
            #
            # @param binding [Object] The object from which to compute a key.
            def apply(binding)
              binding.touch if binding.respond_to?(:touch)
            end
          end

        end
      end
    end
  end
end
