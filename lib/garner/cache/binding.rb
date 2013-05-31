# Set up Garner configuration parameters
Garner.config.option(:binding_key_strategy, {
  :default => Garner::Strategies::BindingKey::CacheKey
})

module Garner
  module Cache
    module Binding

      # Override this method to use a custom key strategy for this class.
      #
      # @return [Object] The
      def key_strategy
        Garner.config.binding_key_strategy
      end

      #
      #
      def garner_cache_key
        key_strategy.apply(self)
      end

      # Invalidate caches. Called by mixins whenever an object is known to
      # have changed. Override for non-trivial behavior.
      def invalidate_garner_caches
      end

    end
  end
end
