module Garner
  module Cache
    IDENTITY_FIELDS = [ :id ]

    KEY_STRATEGIES = [
      Garner::Strategies::Keys::Caller,
      Garner::Strategies::Keys::RequestPath,
      Garner::Strategies::Keys::RequestGet,
      Garner::Strategies::Keys::RequestPost
    ]

    CACHE_STRATEGIES = [
      Garner::Strategies::Cache::Expiration
    ]

    class << self

      # cache the result of an executable block
      def fetch(binding = nil, context = {}, &block)
        cache_options = apply_cache_options(context)
        key = key(binding, key_context(context))
        result = Garner.config.cache.fetch(key, cache_options) do
          binding ? yield(binding) : yield
        end
        Garner.config.cache.delete(key) unless result
        result
      end

      # invalidate an object that has been cached
      def invalidate(*args)
        options = index(*args)
        reset_key_prefix_for(options[:klass], options[:object])
        reset_key_prefix_for(options[:klass]) if options[:object]
      end

      private
      # write an object to cache
      def write(key, binding, cache_options = {}, &block)
        object = binding ? yield(binding) : yield
        if object
          Garner.config.cache.write(key, object, cache_options)
        end
        Garner.config.cache.delete(key) unless object
        object
      end

      # applied cache options
      def apply_cache_options(context)
        cache_options = context[:cache_options] || {}
        CACHE_STRATEGIES.each do |strategy|
          cache_options = strategy.apply(cache_options)
        end
        cache_options
      end

      # applied key context
      def key_context(context)
        new_context = {}
        context ||= {}
        KEY_STRATEGIES.each do |strategy|
          new_context = strategy.apply(new_context, context)
        end
        new_context
      end

      def reset_key_prefix_for(klass, object = nil)
        Garner.config.cache.delete(index_string_for(klass, object))
      end

      def new_key_prefix_for(klass, object = nil)
        Digest::MD5.hexdigest("#{klass}/#{object || "*"}:#{new_key_postfix}")
      end

      # Generate a key in the Klass/id format.
      # @example Widget/id=1,Gadget/slug=forty-two,Fudget/*
      def key(binding = nil, context = {})
        bound = binding && binding[:bind] ? standardize(binding[:bind]) : {}
        bound = (bound.is_a?(Array) ? bound : [ bound ]).compact
        bound.collect { |el|
          if el[:object] && ! IDENTITY_FIELDS.map { |id| el[:object][id] }.compact.any?
            raise ArgumentError, ":bind object arguments (#{bound}) can only be keyed by #{IDENTITY_FIELDS.join(", ")}"
          end
          find_or_create_key_prefix_for(el[:klass], el[:object])
        }.join(",") + ":" +
        Digest::MD5.hexdigest(
          KEY_STRATEGIES.map { |strategy| context[strategy.field] }.uniq.compact.join("\n")
        )
      end

      # Generate an index key from args
      def index(*args)
        case args[0]
        when Hash
          args[0]
        when Class
          case args[1]
          when Hash
            { :klass => args[0], :object => args[1] }
          when NilClass
            { :klass => args[0] }
          else
            { :klass => args[0], :object => { IDENTITY_FIELDS.first => args[1] } }
          end
        else
          raise ArgumentError, "invalid args, must be (klass, identifier) or hash (#{args})"
        end
      end

      def find_or_create_key_prefix_for(klass, object = nil)
        Garner.config.cache.fetch(index_string_for(klass, object), {}) do
          new_key_prefix_for(klass, object)
        end
      end

      def new_key_prefix_for(klass, object = nil)
        Digest::MD5.hexdigest("#{klass}/#{object || "*"}:#{new_key_postfix}")
      end

      def new_key_postfix
        SecureRandom.respond_to?(:uuid) ? SecureRandom.uuid : (0...16).map{ ('a'..'z').to_a[rand(26)] }.join
      end

      def standardize(binding)
        case binding
        when Hash
          binding
        when Array
          bind_array(binding)
        when NilClass
          nil
        end
      end

      def bind_array(ary)
        case ary[0]
        when Array, Hash
          ary.collect { |subary| standardize(subary) }
        when Class
          h = { :klass => ary[0] }
          h.merge!({
            :object => (ary[1].is_a?(Hash) ? ary[1] : { IDENTITY_FIELDS.first => ary[1] })
          }) if ary[1]
          h
        else
          raise ArgumentError, "invalid argument type #{ary[0].class} in :bind (#{ary[0]})"
        end
      end

      def index_string_for(klass, object = nil)
        prefix = "INDEX"
        IDENTITY_FIELDS.each do |field|
          if object && object[field]
            return "#{prefix}:#{klass}/#{field}=#{object[field]}"
          end
        end
        "#{prefix}:#{klass}/*"
      end
    end
  end
end
