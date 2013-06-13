require "spec_helper"
require "garner/mixins/mongoid"

describe Garner::Mixins::Mongoid::Identity do
  subject { Garner::Mixins::Mongoid::Identity.new }
    before(:each) do
      @mock_strategy = double "strategy"
      @mock_strategy.stub(:apply)
      @mock_strategy_class.stub(:new) { @mock_strategy }
      @mock_mongoid_strategy = double "mongoid_strategy"
      @mock_mongoid_strategy.stub(:apply)
      @mock_mongoid_strategy_class.stub(:new) { @mock_mongoid_strategy }
    end

  it "accepts a different key strategy than the global default" do
    Garner.configure do |config|
      config.binding_key_strategy = @mock_strategy_class
      config.mongoid_binding_key_strategy = @mock_mongoid_strategy_class
    end

    @mock_mongoid_strategy.should_receive(:apply).with(subject)
    subject.garner_cache_key
  end

  it "accepts a different invalidation strategy than the global default" do
    Garner.configure do |config|
      config.binding_invalidation_strategy = @mock_strategy_class
      config.mongoid_binding_invalidation_strategy = @mock_mongoid_strategy_class
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

    it "sets collection_name and a conditions hash" do
      identity = subject.from_class_and_id(Monger, "id")
      identity.collection_name.should == :mongers
      identity.conditions["$or"].should == [
        { :_id => "id" },
        { :_slugs => "id" }
      ]
    end

    context "on a Mongoid subclass" do
      it "sets collection_name to parent and includes the _type field" do
        identity = subject.from_class_and_id(Cheese, "id")
        identity.collection_name.should == :foods
        identity.conditions[:_type].should == { "$in" => ["Cheese"] }
        identity.conditions["$or"].should == [
          { :_id => "id" },
          { :_slugs => "id" }
        ]
      end
    end
  end

  describe "cache_key" do
    before(:each) do
      Garner.configure do |config|
        config.mongoid_identity_fields = [:_id, :_slugs]
      end

      @monger = Monger.create({ :name => "M1" })
      @cheese = Cheese.create({ :name => "Havarti" })
    end

    it "generates a cache key equivalent to Mongoid::Document's" do
      Monger.identify("m1").cache_key.should == @monger.cache_key

      # Also test for Mongoid subclasses
      Cheese.identify("havarti").cache_key.should == @cheese.cache_key
      Food.identify("havarti").cache_key.should == @cheese.cache_key
    end

    it "generates a nil cache key if the document is not found" do
      Monger.identify("m2").cache_key.should be_nil
    end

    context "without Mongoid::Timestamps" do
      before(:each) do
        @monger.unset(:updated_at)
        @cheese.unset(:updated_at)
      end

      it "generates a cache key equivalent to Mongoid::Document's" do
        Monger.identify("m1").cache_key.should == @monger.cache_key

        # Also test for Mongoid subclasses
        Cheese.identify("havarti").cache_key.should == @cheese.cache_key
        Food.identify("havarti").cache_key.should == @cheese.cache_key
      end
    end
  end
end
