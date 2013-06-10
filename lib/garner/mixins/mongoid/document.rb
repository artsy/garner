# Set up Garner configuration parameters
Garner.config.option(:mongoid_binding_key_strategy, {
  :default => Garner.config.binding_key_strategy
})

Garner.config.option(:mongoid_binding_invalidation_strategy, {
  :default => Garner.config.binding_invalidation_strategy
})

module Garner
  module Mixins
    module Mongoid
      module Document
        extend ActiveSupport::Concern
        include Garner::Cache::Binding

        def key_strategy
          Garner.config.mongoid_binding_key_strategy
        end

        def invalidation_strategy
          Garner.config.mongoid_binding_invalidation_strategy
        end

        included do
          extend Garner::Cache::Binding

          def self.key_strategy
            Garner.config.mongoid_binding_key_strategy
          end

          def self.invalidation_strategy
            Garner.config.mongoid_binding_invalidation_strategy
          end

          def self.identify(id)
            Garner::Mixins::Mongoid::Identity.from_class_and_id(self, id)
          end

          def self.garnered_find(id)
            return nil unless (binding = identify(id))
            identity = Garner::Cache::Identity.new
            identity.bind(binding).key({ :source => :garnered_find }) { find(id) }
          end

          after_create    :invalidate_garner_caches
          after_update    :invalidate_garner_caches
          before_destroy  :invalidate_garner_caches
        end

      end
    end
  end
end
