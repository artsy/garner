# Set up Garner configuration parameters
Garner.config.option(:binding_key_strategy, {
  :default => Garner::Strategies::Binding::Key::SafeCacheKey
})
Garner.config.option(:binding_invalidation_strategy, {
  :default => Garner::Strategies::Binding::Invalidation::Touch
})
Garner.config.option(:mongoid_identity_fields, {
  :default => [:_id]
})

module Garner
  module Cache
    module Binding

      # Override this method to use a custom key strategy.
      #
      # @return [Object] The strategy to be used for instances of this class.
      def key_strategy
        Garner.config.binding_key_strategy
      end

      # Apply the cache key strategy to this binding.
      def garner_cache_key
        key_strategy.apply(self)
      end

      # Override this method to use a custom invalidation strategy.
      #
      # @return [Object] The strategy to be used for instances of this class.
      def invalidation_strategy
        Garner.config.binding_invalidation_strategy
      end

      # Apply the invalidation strategy to this binding.
      def invalidate_garner_caches
        invalidation_strategy.apply(self)
      end

      protected
      def _garner_after_create
        if invalidation_strategy.apply_on_callback?(:create)
          invalidation_strategy.apply(self)
        end
      end

      def _garner_after_update
        if invalidation_strategy.apply_on_callback?(:update)
          invalidation_strategy.apply(self)
        end
      end

      def _garner_after_destroy
        if invalidation_strategy.apply_on_callback?(:destroy)
          invalidation_strategy.apply(self)
        end
      end

    end
  end
end
