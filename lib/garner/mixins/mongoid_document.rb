# Set up Garner configuration parameters
Garner.config.option(:default_identity_field, { :default => :_id })
Garner.config.option(:mongoid_identity_fields, { :default => [:_id] })

module Garner
  module Mixins
    module Mongoid
      module Document
        extend ActiveSupport::Concern

        extend Garner::Cache::Binding
        include Garner::Cache::Binding

        included do
          after_create :invalidate_garner_caches
          after_update :invalidate_garner_caches
          after_destroy :invalidate_garner_caches
        end

        module ClassMethods
          def garner_index_key
            root_mongoid_class.name
          end

          def all_garner_index_keys
            [ garner_index_key ]
          end

          def root_mongoid_class
            if superclass == Object || superclass.nil? || !superclass.include?(Mongoid::Document)
              self
            else
              superclass.root_mongoid_class
            end
          end
        end

        def garner_index_key
          value = send(Garner.config.default_identity_field)
          "#{self.class.root_mongoid_class}/#{value.to_s}"
        end

        def all_garner_index_keys
          instance_keys = Garner.config.mongoid_identity_fields.map { |field|
            if respond_to?(field)
              if (value = send(field)).is_a?(Array)
                value.map { |element| "#{self.class.root_mongoid_class}/#{element}" }
              else
                "#{self.class.root_mongoid_class}/#{value.to_s}"
              end
            else
              nil
            end
          }.flatten.compact
          class_keys = self.class.all_garner_index_keys
          instance_keys + class_keys
        end

      end
    end
  end
end

