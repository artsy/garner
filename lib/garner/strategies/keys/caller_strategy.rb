module Garner
  module Strategies
    module Keys
      # Injects the caller's location into the key.
      module Caller
        class << self
          def apply(key, options = {})
            rc = key ? key.dup : {}
            clr = caller.detect { |line| ! line.end_with?("/#{File.basename(__FILE__)}") }
            rc[:caller] = clr if clr
            rc
          end
        end
      end
    end
  end
end
