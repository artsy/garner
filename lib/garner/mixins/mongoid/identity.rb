module Garner
  module Mixins
    module Mongoid
      class Identity
        include Garner::Cache::Binding

        attr_accessor :klass, :handle, :proxy_binding, :conditions

        def self.from_class_and_handle(klass, handle)
          validate_class!(klass)

          self.new.tap do |identity|
            identity.klass = klass
            identity.handle = handle
            identity.conditions = conditions_for(klass, handle)
          end
        end

        def initialize
          @conditions = {}
        end

        def proxy_binding
          @proxy_binding ||= klass.where(conditions).only(:_id, :_type, :updated_at).first
        end

        private
        def self.validate_class!(klass)
          if !klass.include?(::Mongoid::Document)
            raise "Must instantiate from a Mongoid class"
          elsif klass.embedded?
            raise "Cannot instantiate from an embedded document class"
          end
        end

        def self.conditions_for(klass, handle)
          # multiple-ID conditions
          conditions = {
            "$or" => Garner.config.mongoid_identity_fields.map { |field|
              { field => handle }
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
