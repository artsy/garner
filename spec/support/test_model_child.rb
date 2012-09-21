class TestModelChild
  include Mongoid::Document
  include Garner::Mixins::Mongoid::Document
  cache_as ::TestModel
end