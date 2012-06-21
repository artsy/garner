require 'spec_helper'

describe Garner::Mixins::Grape do
  include Rack::Test::Methods
  def app
    Class.new(Grape::API).tap do |api|
      api.helpers Garner::Mixins::Grape::Cache
      api.format :json
      api.get "/" do
        cache do
          { :meaning_of_life => 42 }
        end
      end
      api.get "/widget/:id" do
        @counts ||= {}
        cache_or_304(bind: [Module, params[:id]]) do
          @counts[params[:id]] = (@counts[params[:id]] || 0) + 1
          MultiJson.dump({ :count => @counts[params[:id]] })
        end
      end
    end
  end
  before :each do
    Garner.config.cache.clear
  end
  context "cache" do
    it "writes record to cache along with index" do
      Garner.config.cache.should_receive(:write).exactly(3).times
      get "/"
      last_response.body.should == MultiJson.dump({ :meaning_of_life => 42 })
    end
  end
  context "cache_or_304" do
    it "writes the cached object's timestamp and ETag from binding" do
      get "/widget/42"
      last_response.headers["ETag"].length.should == 32 + 2
      Time.parse(last_response.headers["Last-Modified"]).should be_within(1.second).of(Time.now)
    end
    it "sends a 304 response if content has not changed (If-None-Match)" do
      get "/widget/42"
      last_response.status.should == 200
      get "/widget/42", {}, { "HTTP_IF_NONE_MATCH" => last_response.headers["ETag"] }
      last_response.status.should == 304
    end
  end
end