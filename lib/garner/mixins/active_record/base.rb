require "garner"
require "active_record"

module Garner
  module Mixins
    module ActiveRecord
      module Base
        include Garner::Cache::Binding
      end
    end
  end
end
