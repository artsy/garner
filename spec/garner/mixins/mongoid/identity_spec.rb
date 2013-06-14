require "spec_helper"
require "garner/mixins/mongoid"

describe Garner::Mixins::Mongoid::Identity do
  before(:each) do
    @mock_strategy = double("strategy")
    @mock_strategy.stub(:apply)
    @mock_mongoid_strategy = double("mongoid_strategy")
    @mock_mongoid_strategy.stub(:apply)
  end

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

  context "with default configuration and real documents" do
    before(:each) do
      Garner.configure do |config|
        config.mongoid_identity_fields = [:_id, :_slugs]
      end

      @monger = Monger.create({ :name => "M1" })
      @cheese = Cheese.create({ :name => "Havarti" })
    end

    describe "cache_key" do
      it "generates a cache key equal to Mongoid::Document's" do
        Monger.identify("m1").cache_key.should == @monger.cache_key

        # Also test for Mongoid subclasses
        Cheese.identify("havarti").cache_key.should == @cheese.cache_key
        Food.identify("havarti").cache_key.should == @cheese.cache_key
        Monger.identify("m2").cache_key.should == Monger.new({ :name => "M2" }).cache_key
      end

      context "without Mongoid::Timestamps" do
        before(:each) do
          @monger.unset(:updated_at)
          @cheese.unset(:updated_at)
        end

        it "generates a cache key equal to Mongoid::Document's" do
          Monger.identify("m1").cache_key.should == @monger.cache_key

          # Also test for Mongoid subclasses
          Cheese.identify("havarti").cache_key.should == @cheese.cache_key
          Food.identify("havarti").cache_key.should == @cheese.cache_key
        end
      end
    end
    describe "updated_at" do
      it "returns :updated_at equal to Mongoid::Document's" do
        Monger.identify("m1").updated_at.should == Monger.find("m1").updated_at

        # Also test for Mongoid subclasses
        Cheese.identify("havarti").updated_at.should == Cheese.identify("havarti").updated_at
        Food.identify("havarti").updated_at.should == Food.identify("havarti").updated_at
        Monger.identify("m2").updated_at.should == Monger.new({ :name => "M2" }).updated_at
      end
    end
  end
end
