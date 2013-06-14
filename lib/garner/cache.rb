module Garner
  module Cache

    # Fetch a result from cache.
    #
    # @param bindings [Array] Objects to which the the cache result should be
    #        bound. These objects' keys are injected into the compound cache key.
    # @param key_hash [Hash] Hash to comprise the compound cache key.
    # @param options_hash [Hash] Options to be passed to Garner.config.cache.
    def self.fetch(bindings, key_hash, options_hash, &block)
      if (compound_key = compound_key(bindings, key_hash))
        result = Garner.config.cache.fetch(compound_key, options_hash) do
          yield
        end
        Garner.config.cache.delete(compound_key) unless result
      else
        result = yield
      end
      result
    end

    private
    def self.compound_key(bindings, key_hash)
      binding_keys = bindings.map(&:garner_cache_key).compact

      if binding_keys.size == bindings.size
        # All bindings have non-nil cache keys, proceed.
        {
          :binding_keys => binding_keys,
          :context_keys => key_hash
        }
      else
        # A nil cache key was generated. Skip caching.
        # TODO: Replace this ill-documented "nil to skip" behavior
        # with exceptions on inability to generate a cache key.
        nil
      end
    end

  end
end
