module Garner
  module Strategies
    module Binding
      module Invalidation
        class Base
          # Specifies whether invalidation should happen on callbacks.
          #
          # @param kind [Symbol] One of :create, :update, :destroy
          def self.apply_on_callback?(_kind = nil)
            true
          end

          # Force-invalidate an object binding. Used when bindings are
          # explicitly invalidated, via binding.invalidate_garner_caches.
          #
          # @param binding [Object] The binding whose caches are to be
          #   invalidated.
          def self.apply(_binding)
          end
        end
      end
    end
  end
end
