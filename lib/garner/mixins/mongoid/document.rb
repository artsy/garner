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

          after_create    :invalidate_garner_caches
          after_update    :invalidate_garner_caches
          before_destroy  :invalidate_garner_caches
        end

      end
    end
  end
end
