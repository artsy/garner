require "spec_helper"
require "garner/mixins/rack"

describe Garner::Mixins::Rack do

  describe "garner" do

    before(:each) do
      class MockApp
        include Garner::Mixins::Rack

        def request
          Rack::Request.new({
            "REQUEST_METHOD" => "GET",
            "QUERY_STRING" => "foo=bar"
          })
        end
      end

      @mock_app = MockApp.new
    end

    subject do
      lambda { @mock_app.garner }
    end

    it "returns a Garner::Cache::Identity" do
      subject.call.should be_a(Garner::Cache::Identity)
    end

    it "sets the identity's ruby_binding to self" do
      subject.call.ruby_context.should == @mock_app
    end

    it "applies each of Garner.config.rack_context_key_strategies" do
      # Default :context_key_strategies
      subject.call.key_hash[:caller].should_not be_nil
      subject.call.key_hash[:request_params].should == { "foo" => "bar" }

      # Custom :context_key_strategies
      Garner.configure do |config|
        config.rack_context_key_strategies = [
          Garner::Strategies::Context::Key::RequestGet
        ]
      end
      subject.call.key_hash[:caller].should be_nil
      subject.call.key_hash[:request_params].should == { "foo" => "bar" }
    end

  end
end
