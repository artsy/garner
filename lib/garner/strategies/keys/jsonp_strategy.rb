module Garner
  module Strategies
    module Keys
      # Strips JSONP parameters from the key.
      module Jsonp
        class << self

          def field
            :params
          end

          def apply(key, context = {})
            key = key ? key.dup : {}
            return unless key[field]
            key[field].delete("callback")
            key[field].delete("_")
            key
          end

        end
      end
    end
  end
end
