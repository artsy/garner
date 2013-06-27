module Garner
  module Strategies
    module Binding
      module Invalidation
        class BindingIndex < Base

          # Specifies whether invalidation should happen on callbacks.
          #
          # @param kind [Symbol] One of :create, :update, :destroy
          def self.apply_on_callback?(kind = nil)
            true
          end

          # Force-invalidate an object binding. Used when bindings are
          # explicitly invalidated, via binding.invalidate_garner_caches.
          #
          # @param binding [Object] The binding whose caches are to be
          #   invalidated.
          def self.apply(binding)
            Key::BindingIndex.write_canonical_binding_for(binding)
            Key::BindingIndex.write_cache_key_for(binding)

            # Invalidate proxied classes
            if binding.respond_to?(:proxied_classes)
              binding.proxied_classes.each do |klass|
                Key::BindingIndex.write_cache_key_for(klass)
              end
            end
          end
        end
      end

    end
  end
end
