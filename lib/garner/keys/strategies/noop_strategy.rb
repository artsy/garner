module Garner
  module Keys
    module Strategies
      # @abstract
      # A noop base strategy
      module Noop
        class << self
          def apply(key, options = {})
            key
          end
        end
      end
    end
  end
end
