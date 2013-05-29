module Garner
  module Cache
    module Binding

      # Binding-extended classes should implement invalidate_garner_caches.
      # If left unimplemented, invalidation will have no effect.
      def invalidate_garner_caches
      end

      # Binding-extended classes should implement garner_cache_key. If left
      # unimplemented, cache results bound to this object will always be
      # computed, never cached.
      #
      # @return [String] A cache key string.
      def default_cache_key
      end

      # All valid cache keys for this object. Used by the IndexedIdentites
      # and DeclaredIdentities strategies.
      #
      # @return [Array] An array of cache key strings.
      def all_cache_keys
      end

    end
  end
end
