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
            raise "missing :request in options" unless context[:request]
            raise "invalid :request in options" unless context[:request].respond_to?(:GET)
            rc = key ? key.dup : {}
            rc[field] = {} unless rc[field]
            rc[field].merge!(context[:request].GET.dup)
            rc
          end
          
        end
      end
    end
  end
end
