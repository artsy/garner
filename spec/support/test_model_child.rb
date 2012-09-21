require "#{File.dirname(__FILE__)}/test_model.rb"

class TestModelChild
  include Mongoid::Document
  include Garner::Mixins::Mongoid::Document
  cache_as TestModel
end