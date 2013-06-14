require "spec_helper"
require "garner/mixins/mongoid"

describe Garner::Mixins::Mongoid::Document do
  [Monger, Monger.create].each do |binding|
    context "at the #{binding.is_a?(Class) ? "class" : "instance" } level" do
      before(:each) do
        @mock_strategy = double("strategy")
        @mock_strategy.stub(:apply)
        @mock_mongoid_strategy = double("mongoid_strategy")
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

  context "at the class level" do
    subject { Monger }

    describe "_latest_by_updated_at" do
      it "returns a Mongoid::Document instance" do
        subject.create
        subject.send(:_latest_by_updated_at).should be_a(subject)
      end

      it "returns the _latest_by_updated_at document by :updated_at" do
        mongers = 3.times.map { subject.create }
        mongers[1].touch

        subject.send(:_latest_by_updated_at)._id.should == mongers[1]._id
        subject.send(:_latest_by_updated_at).updated_at.should == mongers[1].reload.updated_at
      end

      it "returns nil if there are no documents" do
        subject.send(:_latest_by_updated_at).should be_nil
      end

      it "returns nil if updated_at does not exist" do
        monger = subject.create
        subject.stub(:fields) { {} }
        subject.send(:_latest_by_updated_at).should be_nil
      end
    end

    describe "touch" do
      it "touches the _latest_by_updated_at document" do
        monger = subject.create
        subject.any_instance.should_receive(:touch)
        subject.touch
      end
    end

    describe "cache_key" do
      it "return's the _latest_by_updated_at document's cache key" do
        monger = subject.create
        subject.any_instance.should_receive(:cache_key)
        subject.cache_key
      end

      it "matches what would be returned from the full object" do
        monger = subject.create
        subject.cache_key.should == monger.reload.cache_key
      end

      context "with Mongoid subclasses" do
        subject { Cheese }

        it "matches what would be returned from the full object" do
          cheese = subject.create
          subject.cache_key.should == cheese.reload.cache_key
        end
      end
    end
  end
end
