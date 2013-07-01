require "garner"

module Garner
  module Mixins
    module Rack

      # Override this method to conditionally disable the cache.
      #
      # @return [Boolean]
      def cache_enabled?
        true
      end

      # Instantiate a context-appropriate cache identity.
      #
      # @example
      #   garner.bind(current_user) do
      #     { count: current_user.logins.count }
      #   end
      # @return [Garner::Cache::Identity] The cache identity.
      def garner(&block)
        identity = Garner::Cache::Identity.new(self)
        Garner.config.rack_context_key_strategies.each do |strategy|
          identity = strategy.apply(identity, self)
        end

        identity = identity.nocache unless cache_enabled?

        block_given? ? identity.fetch(&block) : identity
      end
    end
  end
end
