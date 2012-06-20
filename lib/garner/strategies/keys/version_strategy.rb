module Garner
  module Strategies
    module Keys
      # Inject the request path into the key.
      module Version
        class << self
        
          def field
            :version
          end
          
          def default_version
            nil
          end
          
          def apply(key, context = {})
            key = key ? key.dup : {}
            if context && context[:version]
              key[:version] = context[:version] 
            elsif default_version
              key[:version] = default_version
            end
            key
          end
        end
      end
    end
  end
end
