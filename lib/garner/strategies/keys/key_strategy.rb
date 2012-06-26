module Garner
  module Strategies
    module Keys
      # Inject a key into the cache key.
      module Key
        class << self
        
          def field
            :key
          end
          
          def apply(key, context = {})
            key = key ? key.dup : {}
            key[field] = context[:key] if context && context.has_key?(:key)
            key
          end
        end
      end
    end
  end
end
