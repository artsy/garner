module Garner
  module Cache

    class << self

      # Fetch a result from cache.
      #
      # @param bindings [Array] Objects to which the the cache result should be
      #        bound. These objects' keys are injected into the compound cache key.
      # @param key_hash [Hash] Hash to comprise the compound cache key.
      # @param options_hash [Hash] Options to be passed to Garner.config.cache.
      def fetch(bindings, key_hash, options_hash, &block)
        compound_key = {
          :bindings => bindings.map(&:garner_cache_key),
          :keys => key_hash
        }
        result = Garner.config.cache.fetch(compound_key, options_hash) do
          binding ? yield(binding) : yield
        end
        Garner.config.cache.delete(compound_key) unless result
        result
      end

    end
  end
end
