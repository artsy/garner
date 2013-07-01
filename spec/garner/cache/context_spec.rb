require "spec_helper"

describe Garner::Cache::Context do

  describe "garner" do

    before(:each) do
      class TestContext
        include Garner::Cache::Context
      end
      @test_context = TestContext.new
    end

    subject do
      lambda { @test_context.garner }
    end

    it "returns a Garner::Cache::Identity" do
      subject.call.should be_a(Garner::Cache::Identity)
    end

    it "sets the identity's ruby_binding to self" do
      subject.call.ruby_context.should == @test_context
    end

    it "applies each of Garner.config.context_key_strategies" do
      # Default :context_key_strategies
      subject.call.key_hash[:caller].should_not be_nil

      # Custom :context_key_strategies
      Garner.configure do |config|
        config.context_key_strategies = []
      end
      subject.call.key_hash[:caller].should be_nil
    end

  end
end
