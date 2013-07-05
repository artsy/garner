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
Garner.config.option(:invalidate_mongoid_root, {
  :default => true
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
      #
      # @return [String] A cache key string.
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
      #
      # @return [Boolean] Returns true on success.
      def invalidate_garner_caches
        _invalidate
        true
      end

      protected
      def _invalidate
        invalidation_strategy.apply(self)
      end

      def _garner_after_create
        _invalidate if invalidation_strategy.apply_on_callback?(:create)
      end

      def _garner_after_update
        _invalidate if invalidation_strategy.apply_on_callback?(:update)
      end

      def _garner_after_destroy
        _invalidate if invalidation_strategy.apply_on_callback?(:destroy)
      end

    end
  end
end
