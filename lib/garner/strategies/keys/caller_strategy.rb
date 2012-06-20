module Garner
  module Strategies
    module Keys
      # Injects the caller's location into the key.
      module Caller
        class << self
        
          def field
            :caller
          end
          
          def apply(key, context = {})
            rc = key ? key.dup : {}
            clr = caller.detect { |line|
              line = line.split(":", 2)
              next unless line.length == 2
              ! (line[0].end_with?("/#{File.basename(__FILE__)}") || line[0].end_with?("garner/cache/object_identity.rb"))
            }
            rc[field] = clr if clr
            rc
          end
        end
      end
    end
  end
end
