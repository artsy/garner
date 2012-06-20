module Garner
  module Cache
    # A strategy meta-based cache.
    module Meta
      class << self
      
        def binding_strategy
          Garner::Strategies::Bindings::ObjectIdentity
        end
        
        def cache_strategies
          [ Garner::Strategies::Cache::Expiration ]
        end
        
        def cache(binding, options = {})
          # apply binding and key strategies
          binding = binding || {}
          binding_strategy.key_strategies.each do |strategy| 
            binding = strategy.apply(binding, options)
          end
          # binding strategy
          binding = binding_strategy.apply(binding, options)
          # apply cache strategies          
          cache_options = options[:cache_options] || {}
          cache_strategies.each do |strategy|
            cache_options = strategy.apply(cache_options)
          end
          
          
        end

=begin        
            def reset_key_prefix_for(klass, object = nil)
              Garner.config.cache.write(
                index_string_for(klass, object), 
                new_key_prefix_for(klass, object),
                {}
              )
            end
  
          # Generate a metadata key.
          def metadata_key(binding = {})
            "#{key(binding)}:meta"
          end
          
        
        
    # options set default expiration time and force a miss if specified
    cache_key = keyize(options)
    result = Rails.cache.fetch(cache_key, cache_options) do
      object = yield
      reset_cache_metadata(object, options)
      object
    end
    Rails.cache.delete(cache_key) unless result
    result
  end
  
  # metadata for cached objects:
  #   :etag - Unique hash of object content
  #   :last_modified - Timestamp of last modification event
  def self.cache_metadata(options = {})
    default_metadata = {
      etag: etag_for(SecureRandom.uuid),
      last_modified: Time.now
    }
    options = standardize_options(options)
    Rails.cache.read(metadata_key(options)) || default_metadata
  end
  
  def self.reset_cache_metadata(object, options = {})
    return unless object
    metadata = {
      etag: etag_for(object),
      last_modified: Time.now
    }
    Rails.cache.write(metadata_key(options), metadata)
  end



  # invalidate an object that has been cached
  def self.invalidate(*args)
    options = invalidate_args_to_options(*args)
    reset_key_prefix_for(options[:klass], options[:object])
    reset_key_prefix_for(options[:klass]) if options[:object]
  end
    
  private
  
  def self.find_or_create_key_prefix_for(klass, object = nil)
    cache_options = {}
    Rails.cache.fetch(index_string_for(klass, object), cache_options) do
      new_key_prefix_for(klass, object)
    end
  end
  
  def self.reset_key_prefix_for(klass, object = nil)
    cache_options = {}
    Rails.cache.write(
      index_string_for(klass, object), 
      new_key_prefix_for(klass, object),
      cache_options
    )
  end
  
  def self.new_key_prefix_for(klass, object = nil)
    Digest::MD5.hexdigest("#{klass}/#{object || "*"}:#{SecureRandom.uuid}")
  end

  def self.metadata_key(options = {})
    "#{keyize(options)}:meta"
  end

  
  def self.invalidate_args_to_options(*args)
    case args[0]
    when Hash
      args[0]
    when Class
      case args[1]
      when Hash
        { klass: args[0], object: args[1] }
      when NilClass
        { klass: args[0] }
      else
        { klass: args[0], object: { slug: args[1] } }
      end
    else
      raise "Invalid call to invalidate: call as invalidate(klass, identifier) or invalidate(options)"
    end
  end
end
=end
    end
  end
end
