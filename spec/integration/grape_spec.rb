require 'spec_helper'
require File.join(File.dirname(__FILE__), 'shared/conditional_get')

describe "Grape integration" do
  class TestCachebuster < Garner::Middleware::Base
    def after
      @app_response[1]["Expires"] = Time.at(0).utc.to_s
      @app_response
    end
  end

  let(:app) do
    class TestGrapeApp < Grape::API
      helpers Garner::Mixins::Grape::Cache
      use Rack::ConditionalGet
      use Rack::ETag
      use TestCachebuster

      helpers do
        def cache_enabled?
          ENV['CACHE_DISABLED'] != "1"
        end
      end

      format :json

      get "/" do
        cache do
          { meaning_of_life: 42 }.to_json
        end
      end
    end

    TestGrapeApp.new
  end

  it_should_behave_like "Rack::ConditionalGet server"
end
