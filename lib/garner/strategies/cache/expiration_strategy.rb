module Garner
  module Strategies
    module Cache
      # Injects an expires_in value from the global configuration.
      module Expiration
        class << self
          def apply(current, options = {})
            rc = current ? current.dup : {}
            rc[:expires_in] = Garner.config.expires_in if Garner.config.expires_in && ! current[:expires_in]
            rc
          end
        end
      end
    end
  end
end
