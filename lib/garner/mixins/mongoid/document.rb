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
          Garner.config.mongoid_binding_key_strategy.new
        end

        def invalidation_strategy
          Garner.config.mongoid_binding_invalidation_strategy.new
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

        included do
          extend Garner::Cache::Binding

          def self.key_strategy
            Garner.config.mongoid_binding_key_strategy.new
          end

          def self.invalidation_strategy
            Garner.config.mongoid_binding_invalidation_strategy.new
          end

          def self.identify(id)
            Garner::Mixins::Mongoid::Identity.from_class_and_id(self, id)
          end

          def self.garnered_find(id)
            return nil unless (binding = identify(id))
            identity = Garner::Cache::Identity.new
            identity.bind(binding).key({ :source => :garnered_find }) { find(id) }
          end

          after_create    :_garner_after_create
          after_update    :_garner_after_update
          after_destroy   :_garner_after_destroy
        end

      end
    end
  end
end
