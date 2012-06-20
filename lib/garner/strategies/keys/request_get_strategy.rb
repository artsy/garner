module Garner
  module Strategies
    module Keys
      # Inject the request GET parameters into the key.
      module RequestGet
        class << self
        
          def field
            :params
          end
          
          def apply(key, options = {})
            raise "missing :request in options" unless options[:request]
            raise "invalid :request in options" unless options[:request].respond_to?(:GET)
            rc = key ? key.dup : {}
            rc[field] = {} unless rc[field]
            rc[field].merge!(options[:request].GET.dup)
            rc
          end
          
        end
      end
    end
  end
end
