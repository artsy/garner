module Garner
  module Strategies
    module Bindings
      #
      # Object identity binding strategy. 
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
        class << self
        
          def apply(binding, options = {})
            rc = {}
            rc[:bind] = standardize(binding[:bind]) if binding && binding[:bind]
            rc
          end

          def identity_fields
            [ :id ]
          end

          def key_strategies
            [ 
              Garner::Strategies::Keys::Caller, 
              Garner::Strategies::Keys::RequestPath,
              Garner::Strategies::Keys::RequestGet
            ]
          end
          
          # Generate a key in the Klass/id format.
          # @example Widget/id=1,Gadget/slug=forty-two,Fudget/*
          def key(binding)
            raise ArgumentError, "you cannot key nil" unless binding
            rc = binding[:params]
            bound = standardize(binding[:bind])
            bound = (bound.is_a?(Array) ? bound : [ bound ]).compact
            bound.collect { |el|
              if el[:object] && ! identity_fields.map { |id| el[:object][id] }.compact.any?
                raise ArgumentError, ":bind object arguments (#{bound}) can only be keyed by #{identity_fields.join(", ")}"
              end
              find_or_create_key_prefix_for(el[:klass], el[:object])
            }.join(",") + ":" +
            Digest::MD5.hexdigest(
              key_strategies.map { |strategy| binding[strategy.field] }.compact.join("\n") +
              MultiJson.dump((rc || {}).delete_if { |k, v| v.nil? }.to_a)
            )
          end

          private

            def find_or_create_key_prefix_for(klass, object = nil)
              Garner.config.cache.fetch(index_string_for(klass, object), {}) do
                new_key_prefix_for(klass, object)
              end
            end
  
            def new_key_prefix_for(klass, object = nil)
              Digest::MD5.hexdigest("#{klass}/#{object || "*"}:#{SecureRandom.uuid}")
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
                  :object => (ary[1].is_a?(Hash) ? ary[1] : { identity_fields[0] => ary[1] }) 
                }) if ary[1]
                h
              else
                raise ArgumentError, "invalid argument type #{ary[0].class} in :bind (#{ary[0]})"
              end
            end
            
            def index_string_for(klass, object = nil)
              prefix = "INDEX"
              identity_fields.each do |field|
                if object && object[field]
                  return "#{prefix}:#{klass}/#{field}=#{object[field]}"
                end
                "#{prefix}:#{klass}/*"
              end
            end
          
        end
      end
    end
  end
end
