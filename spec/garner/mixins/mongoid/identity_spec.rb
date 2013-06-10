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

  describe "from_class_and_id" do
    before(:each) do
      Garner.configure do |config|
        config.mongoid_identity_fields = [:_id, :_slugs]
      end
    end

    subject { Garner::Mixins::Mongoid::Identity }

    it "raises an exception if called on a non-Mongoid class" do
      expect {
        subject.from_class_and_id(Class.new, "id")
      }.to raise_error

      expect {
        subject.from_class_and_id(Monger.new, "id")
      }.to raise_error
    end

    it "raises an exception if called on an embedded document" do
      expect {
        subject.from_class_and_id(Fish, "id")
      }.to raise_error
    end

    it "sets klass and a conditions hash" do
      identity = subject.from_class_and_id(Monger, "id")
      identity.klass.should == Monger
      identity.conditions["$or"].should == [
        { :_id => "id" },
        { :_slugs => "id" }
      ]
    end

    context "on a Mongoid subclass" do
      it "sets klass to parent and includes the _type field" do
        identity = subject.from_class_and_id(Cheese, "id")
        identity.klass.should == Food
        identity.conditions[:_type].should == { "$in" => ["Cheese"] }
        identity.conditions["$or"].should == [
          { :_id => "id" },
          { :_slugs => "id" }
        ]
      end
    end
  end
end
