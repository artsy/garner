require 'spec_helper'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'shared/conditional_get')

describe "Sinatra integration" do

  let(:app) do
    class TestSinatraApp
      require "sinatra"

      helpers Garner::Mixins::Grape::Cache
      use Rack::ConditionalGet
      use Rack::ETag

      before do
        headers "Expires" => Time.at(0).utc.to_s
      end

      get "/" do
        cache do
          { meaning_of_life: 42 }.to_json
        end
      end
    end

    Sinatra::Application
  end

  it_should_behave_like "Rack::ConditionalGet server"

end