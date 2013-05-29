module Garner
  module Strategies
    module Keys
      module Caller
        class << self

          def field
            :caller
          end

          # Injects the caller's location into the key hash.
          #
          # @param identity [Garner::Cache::Identity] The cache identity.
          # @param ruby_context [Binding] An optional Ruby context.
          # @return [Garner::Cache::Identity] The modified identity.
          def apply(identity, ruby_context = Kernel.binding)
            value = nil

            if ruby_context.send(:caller)
              ruby_context.send(:caller).each do |line|
                next unless line
                split = line.split(":")
                next unless split && split.length >= 2
                path = (Pathname.new(split[0]).realpath.to_s rescue nil)
                next if (! path) || path.empty? || path.include?("lib/garner")
                next unless path.include?("/app/") || path.include?("/spec/")
                value = "#{path}:#{split[1]}"
                break
              end
            end

            value ? identity.key(field => value) : identity
          end
        end
      end
    end
  end
end
