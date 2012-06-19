module Garner
  module Keys
    module Strategies
      # @abstract
      # Inject the request GET parameters into the key.
      module RequestGet
        class << self
          def apply(key, options = {})
            raise "missing :request in options" unless options[:request]
            raise "invalid :request in options" unless options[:request].respond_to?(:GET)
            rc = key ? key.dup : {}
            rc[:params] = {} unless rc[:params]
            rc[:params].merge!(options[:request].GET.dup)
            rc
          end
        end
      end
    end
  end
end
