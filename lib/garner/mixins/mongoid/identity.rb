# Set up Garner configuration parameters
Garner.config.option(:mongoid_identity_fields, {
  :default => [:_id]
})

module Garner
  module Mixins
    module Mongoid
      class Identity
        include Garner::Cache::Binding

        attr_accessor :collection_name, :conditions

        def initialize
          @conditions = {}
        end

        def key_strategy
          Garner.config.mongoid_binding_key_strategy.new
        end

        def invalidation_strategy
          Garner.config.mongoid_binding_invalidation_strategy.new
        end

        def cache_key
          coll = ::Mongoid.default_session[@collection_name]
          query = coll.where(@conditions).select({
            :_id => 1,
            :_type => 1,
            :updated_at => 1
          }).limit(1)
          doc = query.first
          return nil unless doc

          # See https://github.com/mongoid/mongoid/blob/f5ba1295/lib/mongoid/document.rb#L242
          if doc["updated_at"]
            "#{model_cache_key_by_doc(doc)}/#{doc["_id"]}-#{doc["updated_at"].utc.to_s(:number)}"
          else
            "#{model_cache_key_by_doc(doc)}/#{doc["_id"]}"
          end
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

        def model_cache_key_by_doc(doc)
          if doc["_type"]
            ActiveModel::Name.new(doc["_type"].constantize).cache_key
          else
            @collection_name.to_s
          end
        end
      end
    end
  end
end
