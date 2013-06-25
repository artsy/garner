module Garner
  module Strategies
    module Binding
      module Invalidation
        class Touch < Base

          # Specifies whether invalidation should happen on callbacks.
          #
          # @param kind [Symbol] One of :create, :update, :destroy
          def self.apply_on_callback?(kind = nil)
            # Only apply on destruction, so that class bindings remain
            # valid, if the destroyed binding was not also the previous
            # proxy_binding.
            !!(kind == :destroy)
          end

          # Force-invalidate an object binding. Used when bindings are
          # explicitly invalidated, via binding.invalidate_garner_caches.
          #
          # @param binding [Object] The binding whose caches are to be
          #   invalidated.
          def self.apply(binding)
            if  binding.respond_to?(:destroyed?) &&
                binding.destroyed? &&
                binding.class.respond_to?(:proxy_binding)
              # Binding is destroyed, but we must ensure that its class's
              # proxy_binding is touched, if necessary.
              binding = binding.class.proxy_binding

            elsif binding.respond_to?(:proxy_binding)
              binding = binding.proxy_binding
            end

            binding.touch if binding.respond_to?(:touch)
          end
        end
      end

    end
  end
end
