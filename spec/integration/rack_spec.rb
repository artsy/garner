require "spec_helper"
require "garner/mixins/rack"
require "securerandom"

describe "Rack integration" do
  include Rack::Test::Methods

  let(:app) do
    class TestRackApp
      include Garner::Mixins::Rack

      attr_accessor :request

      def call(env)
        @request = Rack::Request.new(env)
        random1 = garner { SecureRandom.hex }
        random2 = garner { SecureRandom.hex }
        [
          200,
          { "Content-Type" => "application/json" },
          [random1, random2].to_json
        ]
      end
    end

    TestRackApp.new
  end

  context "with the RequestGet strategy disabled" do
    before(:each) do
      Garner.configure do |config|
        config.rack_context_key_strategies -= [Garner::Strategies::Context::Key::RequestGet]
      end
    end
    it "co-caches requests to the same path with different query strings" do
      get "/foo?q=1"
      response1 = JSON.parse(last_response.body)[0]
      get "/foo?q=2"
      response2 = JSON.parse(last_response.body)[0]
      response1.should == response2
    end
  end

  context "with default configuration" do
    it "bypasses cache if cache_enabled? returns false" do
      TestRackApp.any_instance.stub(:cache_enabled?) { false }
      get "/"
      response1 = JSON.parse(last_response.body)[0]
      get "/"
      response2 = JSON.parse(last_response.body)[0]
      response1.should_not == response2
    end

    it "caches different results for different paths" do
      get "/foo"
      response1 = JSON.parse(last_response.body)[0]
      get "/bar"
      response2 = JSON.parse(last_response.body)[0]
      response1.should_not == response2
    end

    it "caches different results for different query strings" do
      get "/foo?q=1"
      response1 = JSON.parse(last_response.body)[0]
      get "/foo?q=2"
      response2 = JSON.parse(last_response.body)[0]
      response1.should_not == response2
    end

    it "caches multiple blocks separately within an endpoint" do
      get "/"
      random1 = JSON.parse(last_response.body)[0]
      random2 = JSON.parse(last_response.body)[1]
      random1.should_not == random2
    end
  end
end
