module Garner
  module Strategies
    module Binding
      module Invalidation
        class Touch < Base

          # Specifies whether invalidation should happen on callbacks.
          #
          # @param kind [Symbol] One of :create, :update, :destroy
          def self.apply_on_callback?(kind = nil)
            false
          end

          # Force-invalidate an object binding. Used when bindings are
          # explicitly invalidated, via binding.invalidate_garner_caches.
          #
          # @param binding [Object] The binding whose caches are to be
          #   invalidated.
          def self.apply(binding)
            binding.touch if binding.respond_to?(:touch)
          end
        end
      end

    end
  end
end
