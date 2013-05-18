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
            if context.keys.include?(field)
              rc[field] = context[field]
              return rc
            end

            if caller
              caller.each do |line|
                next unless line
                split = line.split(":")
                next unless split && split.length >= 2
                path = (Pathname.new(split[0]).realpath.to_s rescue nil)
                next if (! path) || path.empty? || path.include?("lib/garner")
                next unless path.include?("/app/") || path.include?("/spec/")
                rc[field] = "#{path}:#{split[1]}"
                break
              end
            end

            rc
          end
        end
      end
    end
  end
end
