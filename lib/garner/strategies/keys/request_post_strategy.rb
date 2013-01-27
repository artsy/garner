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
            if context && (request = context[:request]) && request.request_method == "POST"
              key[field] = request.POST.dup
            end
            key
          end
          
        end
      end
    end
  end
end
