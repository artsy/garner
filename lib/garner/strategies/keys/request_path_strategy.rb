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
            raise "missing :request in context" unless context[:request]
            raise "invalid :request in context" unless context[:request].respond_to?(:path)
            (key || {}).merge({ 
              field => context[:request].path 
            })
          end
        end
      end
    end
  end
end
