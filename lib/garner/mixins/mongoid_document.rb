require "garner"

# Set up Garner configuration parameters
Garner.config.option(:mongoid_binding_key_strategy, {
  :default => Garner::Strategies::BindingKey::CacheKey
})

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

      end
    end
  end
end

