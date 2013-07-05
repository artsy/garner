module Garner
  module Strategies
    module Binding
      module Key
        class BindingIndex < Base
          RANDOM_KEY_LENGTH = 12  # In bytes.

          # Compute a cache key as follows:
          # 1. Determine whether the binding is canonical.
          # 2. If canonical, fetch the cache key stored for binding.class,
          #    binding.id
          # 3. If not canonical, determine the canonical ID from a proxy
          #    binding. Proxy bindings must implement `proxy_binding` and
          #    `handle`.
          #
          # @param binding [Object] The object from which to compute a key.
          # @return [String] A cache key string.
          def self.apply(binding)
            fetch_cache_key_for(binding)
          end

          # Fetch cache key, from cache, for the given binding. Generate a
          # random key, if not already extant.
          #
          # @param binding [Object] The object from which to compute a key.
          # @return [String] A cache key string.
          def self.fetch_cache_key_for(binding)
            canonical_binding = fetch_canonical_binding_for(binding)
            return nil unless canonical_binding
            key = index_key_for(canonical_binding)
            Garner.config.cache.fetch(key) { new_cache_key_for(canonical_binding) }
          end

          # Overwrite cache key for the given binding.
          #
          # @param binding [Object] The object from which to compute a key.
          # @return [String] A cache key string.
          def self.write_cache_key_for(binding)
            canonical_binding = fetch_canonical_binding_for(binding)
            return nil unless canonical_binding
            key = index_key_for(canonical_binding)
            value = new_cache_key_for(canonical_binding)
            value.tap { |v| Garner.config.cache.write(key, v) }
          end

          # Fetch canonical binding for the given binding.
          #
          # @param binding [Object] The object from which to compute a key.
          # @return [Object] A class, ID pair.
          def self.fetch_canonical_binding_for(binding)
            return binding if canonical?(binding)
            key = index_key_for(binding)
            Garner.config.cache.fetch(key) { canonical_binding_for(binding) }
          end

          # Overwrite canonical binding for the given binding.
          #
          # @param binding [Object] The object from which to compute a key.
          # @return [Object] A class, ID pair.
          def self.write_canonical_binding_for(binding)
            return binding if canonical?(binding)
            key = index_key_for(binding)
            value = canonical_binding_for(binding)
            value.tap { |v| Garner.config.cache.write(key, v) }
          end

          # Return canonical binding for the given binding.
          #
          # @param binding [Object] The (possibly) non-canonical binding.
          # @return binding [Object] The canonical binding.
          def self.canonical_binding_for(binding)
            if canonical?(binding)
              binding
            elsif binding.respond_to?(:proxy_binding)
              canonical_binding_for(binding.proxy_binding)
            else
              nil
            end
          end

          # Determine whether the given binding is canonical.
          #
          # @return [Boolean]
          def self.canonical?(binding)
            # TODO: Implement real logic for determining canonicity.
            binding.is_a?(Mongoid::Document) ||
            (binding.is_a?(Class) && binding.include?(Mongoid::Document))
          end

          private
          def self.index_key_for(binding)
            if binding.respond_to?(:identity_string)
              binding_key = binding.identity_string
            else
              binding_key = binding.to_s
            end

            {
              :strategy => self,
              :proxied_binding => binding_key
            }
          end

          def self.new_cache_key_for(binding)
            SecureRandom.hex(RANDOM_KEY_LENGTH)
          end
        end
      end
    end
  end
end
