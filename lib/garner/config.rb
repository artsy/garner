module Garner

  class << self

    # Set the configuration options. Best used by passing a block.
    #
    # @example Set up configuration options.
    #   Garner.configure do |config|
    #     config.cache = Rails.cache
    #   end
    #
    # @return [ Config ] The configuration object.
    def configure
      block_given? ? yield(Garner::Config) : Garner::Config
    end
    alias :config :configure
  end

  module Config
    extend self

    # Current configuration settings.
    attr_accessor :settings

    # Default configuration settings.
    attr_accessor :defaults

    @settings = {}
    @defaults = {}

    # Define a configuration option with a default.
    #
    # @example Define the option.
    #   Config.option(:cache, :default => nil)
    #
    # @param [ Symbol ] name The name of the configuration option.
    # @param [ Hash ] options Extras for the option.
    #
    # @option options [ Object ] :default The default value.
    def option(name, options = {})
      defaults[name] = settings[name] = options[:default]

      class_eval <<-RUBY
        def #{name}
          settings[#{name.inspect}]
        end

        def #{name}=(value)
          settings[#{name.inspect}] = value
        end

        def #{name}?
          #{name}
        end
      RUBY
    end

    # Returns the default cache store, either Rails.cache or an instance
    # of ActiveSupport::Cache::MemoryStore.
    #
    # @example Get the default cache store
    #   config.default_cache
    #
    # @return [ Cache ] The default cache store instance.
    def default_cache
      if defined?(Rails) && Rails.respond_to?(:cache)
        Rails.cache
      else
        ::ActiveSupport::Cache::MemoryStore.new
      end
    end

    # Returns the cache, or defaults to Rails cache when running in Rails
    # or an instance of ActiveSupport::Cache::MemoryStore otherwise.
    #
    # @example Get the cache.
    #   config.cache
    #
    # @return [ Cache ] The configured cache or a default cache instance.
    def cache
      settings[:cache] = default_cache unless settings.has_key?(:cache)
      settings[:cache]
    end

    # Sets the cache to use.
    #
    # @example Set the cache.
    #   config.cache = Rails.cache
    #
    # @return [ Cache ] The newly set cache.
    def cache=(cache)
      settings[:cache] = cache
    end

    # Reset the configuration options to the defaults.
    #
    # @example Reset the configuration options.
    #   config.reset!
    def reset!
      settings.replace(defaults)
    end

    # Default cache options
    option(:global_cache_options, :default => {})

    # Default cache expiration time.
    option(:expires_in, :default => nil)
  end
end

