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
              split = line.split(":")
              next unless split.length >= 2
              path = Pathname.new(split[0]).realpath.to_s
              next unless path.include?("/app/") || path.include?("/spec/")
              rc[field] = "#{path}:#{split[1]}"
              break
            end
            rc
          end
        end
      end
    end
  end
end
