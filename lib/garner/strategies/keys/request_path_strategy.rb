module Garner
  module Strategies
    module Keys
      # Inject the request path into the key.
      module RequestPath
        class << self
        
          def field
            :path
          end
          
          def apply(key, context = {})
            key = key ? key.dup : {}
            key[field] = context[:request].path if context && context[:request] && context[:request].respond_to?(:path)
            key
          end
        end
      end
    end
  end
end
