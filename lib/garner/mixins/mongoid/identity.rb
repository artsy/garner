# Set up Garner configuration parameters
Garner.config.option(:mongoid_identity_fields, {
  :default => [:_id]
})

module Garner
  module Mixins
    module Mongoid
      class Identity
        include Garner::Cache::Binding

        def key_strategy
          Garner.config.mongoid_binding_key_strategy
        end

        def invalidation_strategy
          Garner.config.mongoid_binding_invalidation_strategy
        end

      end
    end
  end
end
