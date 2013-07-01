module Garner
  module Mixins
    module Mongoid
      module Document
        extend ActiveSupport::Concern
        include Garner::Cache::Binding

        def proxied_classes
          self.class.mongoid_superclasses
        end

        def identity_string
          "#{self.class.name}/id=#{id}"
        end

        included do
          extend Garner::Cache::Binding

          # Return an array of this class and all Mongoid superclasses.
          #
          # @return [Array] An array of classes.
          def self.mongoid_superclasses
            if superclass.include?(Mongoid::Document)
              [self] + superclass.mongoid_superclasses
            else
              [self]
            end
          end

          # Return an object that can act as a binding on this class's behalf.
          #
          # @return [Mongoid::Document]
          def self.proxy_binding
            _latest_by_updated_at
          end

          def self.identify(handle)
            Mongoid::Identity.from_class_and_handle(self, handle)
          end

          # Find an object by _id, or other findable field, first trying to
          # fetch from Garner's cache.
          #
          # @return [Mongoid::Document]
          def self.garnered_find(handle)
            return nil unless (binding = identify(handle))
            identity = Garner::Cache::Identity.new
            identity.bind(binding).key({ :source => :garnered_find }) do
              find(handle)
            end
          end

          after_create    :_garner_after_create
          after_update    :_garner_after_update
          after_destroy   :_garner_after_destroy

          protected
          def self._latest_by_updated_at
            # Only find the latest if we can order by :updated_at
            return nil unless fields["updated_at"]
            only(:_id, :_type, :updated_at).order_by({
              :updated_at => :desc
            }).first
          end

          def _invalidate
            invalidation_strategy.apply(self)

            if _root != self && Garner.config.invalidate_mongoid_root
              invalidation_strategy.apply(_root)
            end
          end

        end
      end
    end
  end
end
