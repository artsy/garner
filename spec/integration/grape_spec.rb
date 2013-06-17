require "spec_helper"
require "garner/mixins/rack"
require "grape"

describe "Grape integration" do
  class TestCachebuster < Grape::Middleware::Base
    def after
      @app_response[1]["Expires"] = Time.at(0).utc.to_s
      @app_response
    end
  end

  let(:app) do
    class TestGrapeApp < Grape::API
      helpers Garner::Mixins::Rack
      use Rack::ConditionalGet
      use Rack::ETag
      use TestCachebuster

      format :json

      get "/" do
        garner do
          { :meaning_of_life => 42 }.to_json
        end
      end
    end

    TestGrapeApp.new
  end

  it_behaves_like "Rack::ConditionalGet server"
end
