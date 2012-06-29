module Garner
  module Strategies
    module ETags
      module Marshal
        class << self
          # @abstract
          # Serialize using Ruby's Marshal.dump.
          def apply(object)
            serialization = ::Marshal.dump(object || "")
            %("#{Digest::MD5.hexdigest(serialization)}")
          end
        end
      end
    end
  end
end
