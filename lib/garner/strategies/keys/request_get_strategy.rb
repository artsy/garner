module Garner
  module Strategies
    module Keys
      # Inject the request GET parameters into the key.
      module RequestGet
        class << self
        
          def field
            :params
          end
          
          def apply(key, context = {})
            key = key ? key.dup : {}
            key[field] = context[:request].GET.dup if context && context[:request]
            key
          end
          
        end
      end
    end
  end
end
