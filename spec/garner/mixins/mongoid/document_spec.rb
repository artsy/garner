require "spec_helper"
require "garner/mixins/mongoid"

describe Garner::Mixins::Mongoid::Document do
  [Monger, Monger.create].each do |binding|
    context "at the #{binding.is_a?(Class) ? "class" : "instance" } level" do
      before(:each) do
        @mock_strategy = double "strategy"
        @mock_strategy.stub(:apply)
        @mock_mongoid_strategy = double "mongoid_strategy"
        @mock_mongoid_strategy.stub(:apply)
      end

      subject { binding }

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
  end
end
