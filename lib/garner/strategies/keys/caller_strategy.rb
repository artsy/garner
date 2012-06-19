module Garner
  module Strategies
    module Keys
      # @abstract 
      # Injects the caller's location into the key.
      module Caller
        class << self
          def apply(key, options = {})
            api_caller = caller.detect { |line| !(line =~ /\/#{File.basename(__FILE__)}/) }
            md = api_caller.match(/(.*\.rb:[0-9]*):/) if api_caller
            key[:caller] = md[1] if md
            key
          end
        end
      end
    end
  end
end
