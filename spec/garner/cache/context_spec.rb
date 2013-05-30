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

    it "applies each of Garner.config.key_strategies" do
      # Default :key_strategies
      subject.call.key_hash[:caller].should_not be_nil

      # Custom :key_strategies
      Garner.configure do |config|
        config.key_strategies = []
      end
      subject.call.key_hash[:caller].should be_nil
    end

  end
end
