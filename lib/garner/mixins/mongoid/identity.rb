# Set up Garner configuration parameters
Garner.config.option(:mongoid_identity_fields, {
  :default => [:_id]
})

module Garner
  module Mixins
    module Mongoid
      class Identity
        include Garner::Cache::Binding

        attr_accessor :klass, :conditions

        def initialize
          @conditions = {}
        end

        def key_strategy
          Garner.config.mongoid_binding_key_strategy
        end

        def invalidation_strategy
          Garner.config.mongoid_binding_invalidation_strategy
        end

        def self.from_class_and_id(klass, id)
          validate_class!(klass)

          self.new.tap do |identity|
            identity.klass = top_level_class_for(klass)
            identity.conditions = conditions_for(klass, id)
          end
        end

        private
        def self.validate_class!(klass)
          if !klass.include?(Mongoid::Document)
            raise "Must instantiate from a Mongoid class"
          elsif klass.embedded?
            raise "Cannot instantiate from an embedded document class"
          end
        end

        def self.top_level_class_for(klass)
          seen = []
          parent = klass
          until !parent.superclass.include?(Mongoid::Document)
            raise "Cycle detected in Mongoid inheritance chain" if seen.include?(parent)
            seen << [parent]
            parent = parent.superclass
          end
          parent
        end

        def self.conditions_for(klass, id)
          # _type conditions
          conditions = klass.where({}).send(:type_selection)

          # multiple-ID conditions
          id_conditions = {
            "$or" => Garner.config.mongoid_identity_fields.map { |field|
              { field => id }
            }
          }
          conditions.merge(id_conditions)
        end
      end
    end
  end
end
