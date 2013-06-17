require "spec_helper"
require "garner/mixins/rack"
require "sinatra"

describe "Sinatra integration" do

  let(:app) do
    class TestSinatraApp < Sinatra::Base
      helpers Garner::Mixins::Rack
      use Rack::ConditionalGet
      use Rack::ETag

      before do
        headers "Expires" => Time.at(0).utc.to_s
      end

      get "/" do
        garner do
          { :meaning_of_life => 42 }.to_json
        end
      end
    end

    TestSinatraApp.new
  end

  it_behaves_like "Rack::ConditionalGet server"

end
