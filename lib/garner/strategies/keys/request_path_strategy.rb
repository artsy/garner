module Garner
  module Strategies
    module Keys
      # Inject the request path into the key.
      module RequestPath
        class << self
          def apply(key, options = {})
            raise "missing :request in options" unless options[:request]
            raise "invalid :request in options" unless options[:request].respond_to?(:path)
            (key || {}).merge({ 
              :path => options[:request].path 
            })
          end
        end
      end
    end
  end
end
