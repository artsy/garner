require "spec_helper"
require "garner/mixins/mongoid"

describe Garner::Mixins::Mongoid::Identity do
  subject { Garner::Mixins::Mongoid::Identity.new }

  it "accepts a different key strategy than the global default" do
    Garner.configure do |config|
      config.binding_key_strategy = @mock_strategy
      config.mongoid_binding_key_strategy = @mock_mongoid_strategy
    end

    @mock_mongoid_strategy.should_receive(:apply).with(subject)
    subject.garner_cache_key
  end

  it "accepts a different invalidation strategy than the global default" do
    Garner.configure do |config|
      config.binding_invalidation_strategy = @mock_strategy
      config.mongoid_binding_invalidation_strategy = @mock_mongoid_strategy
    end

    @mock_mongoid_strategy.should_receive(:apply).with(subject)
    subject.invalidate_garner_caches
  end
end
