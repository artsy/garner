module Garner
  module Cache
    #
    # A cache that uses an object identity binding strategy.
    #
    # Allows some flexibility in how caller binds objects in cache.
    # The binding can be an object, class, array of objects, or array of classes
    # on which to bind the validity of the cached result contained in the subsequent
    # block.
    #
    # @example `bind: { klass: Widget, object: { id: params[:id] } }` will cause a cached instance to be
    # invalidated on any change to the `Widget` object whose slug attribute equals `params[:id]`
    #
    # @example `bind: { klass: User, object: { id: current_user.id } }` will cause a cached instance to be
    # invalidated on any change to the `User` object whose id attribute equals current_user.id.
    # This is one way to bind a cache result to any change in the current user.
    #
    # @example `bind: { klass: Widget }` will cause the cached instance to be invalidated on any change to
    # any object of class Widget. This is the appropriate strategy for index paths like /widgets.
    #
    # @example `bind: [{ klass: Widget }, { klass: User, object: { id: current_user.id } }]` will cause a
    # cached instance to be invalidated on any change to either the current user, or any object of class Widget.
    #
    # @example `bind: [Artwork]` is shorthand for `bind: { klass: Artwork }`
    #
    # @example `bind: [Artwork, params[:id]]` is shorthand for `bind: { klass: Artwork, object: { id: params[:id] } }`
    #
    # @example `bind: [User, { id: current_user.id }] is shorthand for `bind: { klass: User, object: { id: current_user.id } }`
    #
    # @example `bind: [[Artwork], [User, { id: current_user.id }]]` is shorthand for
    # `bind: [{ klass: Artwork }, { klass: User, object: { id: current_user.id } }]`
    #
    module ObjectIdentity
      
      IDENTITY_FIELDS = [ :id ]

      KEY_STRATEGIES = [
        Garner::Strategies::Keys::Caller,
        Garner::Strategies::Keys::Version,
        Garner::Strategies::Keys::RequestPath,
        Garner::Strategies::Keys::RequestGet
      ]
      
      CACHE_STRATEGIES = [
        Garner::Strategies::Cache::Expiration
      ]
      
      class << self

        # cache the result of an executable block
        def cache(binding = nil, context = {})
          # apply cache strategies
          cache_options = cache_options(context)
          CACHE_STRATEGIES.each do |strategy|
            cache_options = strategy.apply(cache_options)
          end
          key = key(binding, key_context(context))
          result = Garner.config.cache.fetch(key, cache_options) do
            object = yield
            reset_cache_metadata(key, object)
            object
          end
          Garner.config.cache.delete(key) unless result
          result
        end
                
        # invalidate an object that has been cached
        def invalidate(* args)
          options = index(*args)
          reset_key_prefix_for(options[:klass], options[:object])
          reset_key_prefix_for(options[:klass]) if options[:object]
        end
        
        # metadata for cached objects:
        #   :etag - Unique hash of object content
        #   :last_modified - Timestamp of last modification event
        def cache_metadata(binding, context = {})
          key = key(binding, key_context(context))
          Garner.config.cache.read(meta(key))
        end
        
        private

          # applied cache options
          def cache_options(context)
            context[:cache_options] || {}
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
             Garner.config.cache.write(
               index_string_for(klass, object),
               new_key_prefix_for(klass, object),
               {}
             )
           end

          def reset_cache_metadata(key, object)
            return unless object
            metadata = {
              :etag => Garner::Objects::ETag.from(object),
              :last_modified => Time.now
            }
            meta_key = meta(key)
            Garner.config.cache.write(meta_key, metadata)
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
              KEY_STRATEGIES.map { |strategy| context[strategy.field] }.compact.join("\n")
            )
          end
        
          # Generate an index key from args
          def index(* args)
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
          
          # Generate a metadata key.
          def meta(key)
            "#{key}:meta"
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
end
