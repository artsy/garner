# Set up Garner configuration parameters
Garner.config.option(:rack_context_key_strategies, {
  :default => [
    Garner::Strategies::ContextKey::Caller,
    Garner::Strategies::ContextKey::RequestGet,
    Garner::Strategies::ContextKey::RequestPost,
    Garner::Strategies::ContextKey::RequestPath
  ]
})

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
        identity = Garner::Cache::Identity.new
        Garner.config.rack_context_key_strategies.each do |strategy|
          identity = strategy.apply(identity, self)
        end

        unless cache_enabled?
          identity.options({ :force_miss => true })
        end

        block_given? ? identity.fetch(&block) : identity
      end
    end
  end
end
