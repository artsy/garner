# Set up Garner configuration parameters
Garner.config.option(:binding_key_strategy, {
  :default => Garner::Strategies::BindingKey::CacheKey
})

module Garner
  module Cache
    module Binding

      def key_strategy
        Garner.config.binding_strategy
      end

      def garner_cache_key
        key_strategy.apply(self)
      end

      # Binding-extended classes should implement invalidate_garner_caches.
      # If left unimplemented, invalidation will have no effect.
      def invalidate_garner_caches
      end

    end
  end
end
