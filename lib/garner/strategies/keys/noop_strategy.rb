module Garner
  module Strategies
    module Keys
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
