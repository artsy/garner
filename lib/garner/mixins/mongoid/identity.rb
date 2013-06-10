# Set up Garner configuration parameters
Garner.config.option(:mongoid_identity_fields, {
  :default => [:_id]
})

module Garner
  module Mixins
    module Mongoid
      module Identity
        extend ActiveSupport::Concern
        include Garner::Cache::Binding

      end
    end
  end
end
