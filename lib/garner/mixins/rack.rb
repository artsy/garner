# Set up Garner configuration parameters
Garner.config.option(:rack_key_strategies, {
  :default => [
    Garner::Strategies::Keys::Caller,
    Garner::Strategies::Keys::RequestGet,
    Garner::Strategies::Keys::RequestPost,
    Garner::Strategies::Keys::RequestPath
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
        Garner.config.rack_key_strategies.each do |strategy|
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
