# Set up Garner configuration parameters
Garner.config.option(:mongoid_identity_fields, {
  :default => [:_id]
})

module Garner
  module Mixins
    module Mongoid
      class Identity
        include Garner::Cache::Binding

        attr_accessor :document, :collection_name, :conditions

        def initialize
          @conditions = {}
        end

        def key_strategy
          Garner.config.mongoid_binding_key_strategy
        end

        def invalidation_strategy
          Garner.config.mongoid_binding_invalidation_strategy
        end

        def safe_cache_key
          # Only return a cache key if :updated_at is defined. If it is,
          # append the fractional portion of the timestamp.
          if updated_at
            decimal_portion = updated_at.utc.to_f % 1
            decimal_string = sprintf("%.10f", decimal_portion).gsub(/^0/, "")
            "#{cache_key}#{decimal_string}"
          end
        end

        def cache_key
          # See https://github.com/mongoid/mongoid/blob/f5ba1295/lib/mongoid/document.rb#L242
          if updated_at
            "#{model_cache_key}/#{_id}-#{updated_at.utc.to_s(:number)}"
          elsif _id
            "#{model_cache_key}/#{_id}"
          else
            "#{model_cache_key}/new"
          end
        end

        def model_cache_key
          if _type
            ActiveModel::Name.new(_type.constantize).cache_key
          else
            @collection_name.to_s
          end
        end

        def _id
          document["_id"] if document
        end

        def updated_at
          document["updated_at"] if document
        end

        def _type
          document["_type"] if document
        end

        def document
          return @document if @document

          collection.where(@conditions).select({
            :_id => 1,
            :_type => 1,
            :updated_at => 1
          }).limit(1).first
        end

        def collection
          ::Mongoid.default_session[@collection_name]
        end

        def self.from_class_and_id(klass, id)
          validate_class!(klass)

          self.new.tap do |identity|
            identity.collection_name = klass.collection_name
            identity.conditions = conditions_for(klass, id)
          end
        end

        private
        def self.validate_class!(klass)
          if !klass.include?(::Mongoid::Document)
            raise "Must instantiate from a Mongoid class"
          elsif klass.embedded?
            raise "Cannot instantiate from an embedded document class"
          end
        end

        def self.conditions_for(klass, id)
          # multiple-ID conditions
          conditions = {
            "$or" => Garner.config.mongoid_identity_fields.map { |field|
              { field => id }
            }
          }

          # _type conditions
          selector = klass.where({})
          conditions.merge!(selector.send(:type_selection)) if selector.send(:type_selectable?)

          conditions
        end
      end
    end
  end
end
