module Garner
  module Strategies
    module Keys
      # Inject the request POST parameters into the key.
      module RequestPost
        class << self
        
          def field
            :params
          end
          
          def apply(key, context = {})
            key = key ? key.dup : {}
            key[field] = context[:request].POST.dup if context && context[:request]
            key
          end
          
        end
      end
    end
  end
end
