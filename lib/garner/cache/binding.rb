# Set up Garner configuration parameters
Garner.config.option(:binding_key_strategy, {
  :default => Garner::Strategies::BindingKey::CacheKey
})
Garner.config.option(:binding_invalidation_strategy, {
  :default => Garner::Strategies::BindingInvalidation::Touch
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
        Garner.config.binding_invalidation_strategy.apply(self)
      end

    end
  end
end
