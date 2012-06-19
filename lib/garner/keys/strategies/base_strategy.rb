module Garner
  module Keys
    module Strategies
      # @abstract
      # A noop base strategy
      module Base
        class << self
          def apply(key, options = {})
            key
          end
        end
      end
    end
  end
end
