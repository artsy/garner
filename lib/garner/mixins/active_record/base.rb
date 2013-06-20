require "garner"
require "active_record"

module Garner
  module Mixins
    module ActiveRecord
      module Base
        extend ActiveSupport::Concern
        include Garner::Cache::Binding

        included do
          extend Garner::Cache::Binding
        end
      end
    end
  end
end
