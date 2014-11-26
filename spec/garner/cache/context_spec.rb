require 'spec_helper'

describe Garner::Cache::Context do

  describe 'garner' do

    before(:each) do
      class TestContext
        include Garner::Cache::Context
      end
      @test_context = TestContext.new
    end

    subject do
      -> { @test_context.garner }
    end

    it 'returns a Garner::Cache::Identity' do
      expect(subject.call).to be_a(Garner::Cache::Identity)
    end

    it "sets the identity's ruby_binding to self" do
      expect(subject.call.ruby_context).to eq @test_context
    end

    it 'applies each of Garner.config.context_key_strategies' do
      # Default :context_key_strategies
      expect(subject.call.key_hash[:caller]).not_to be_nil

      # Custom :context_key_strategies
      Garner.configure do |config|
        config.context_key_strategies = []
      end
      expect(subject.call.key_hash[:caller]).to be_nil
    end

  end
end
