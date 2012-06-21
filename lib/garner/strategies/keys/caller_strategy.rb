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
            clr = nil
            caller.each do |line|
              line = line.split(":", 3)
              next unless line.length == 3
              next unless line[0].include?("/app/") || line[0].include?("/spec/")
              rc[field] = "#{line[0]}:#{line[1]}"
              break
            end
            rc
          end
        end
      end
    end
  end
end
