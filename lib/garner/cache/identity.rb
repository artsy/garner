module Garner
  module Cache
    class Identity
      attr_accessor :bindings, :key_hash, :options_hash

      def initialize
        @bindings = []
        @key_hash = {}

        # Set up options hash with defaults
        @options_hash = Garner.config.global_cache_options || {}
        @options_hash.merge!({ :expires_in => Garner.config.expires_in })
      end

      def fetch(&block)
        Garner::Cache.fetch(@bindings, @key_hash, @options_hash, &block)
      end

      # Bind this cache identity to a (bindable) object.
      #
      # @param bind [Object] An object; should support configured binding strategy.
      def bind(object)
        @bindings << object
        block_given? ? fetch(&block) : self
      end

      # Merge the given hash into the cache identity's key hash.
      #
      # @param hash [Hash] A hash to merge on top of the current key hash.
      def key(hash, &block)
        @key_hash.merge!(hash)
        block_given? ? fetch(&block) : self
      end

      # Merge the given hash into the cache identity's cache options.
      # Any cache_options supported by Garner.config.cache may be passed.
      #
      # @param hash [Hash] Options to pass to Garner.config.cache.
      def options(hash, &block)
        @options.merge!(hash)
        block_given? ? fetch(&block) : self
      end
    end
  end
end
