require 'spec_helper'

describe Garner::Middleware::Cache::Bust do
  include Rack::Test::Methods
  
  def app
    Class.new(Grape::API).tap do |api|
      api.format :json
      api.use Garner::Middleware::Cache::Bust
      api.get "/" do
        { :meaning_of_life => 42 }
      end
    end
  end
  
  it "adds Cache-Control, Pragma and Expires headers" do
    get "/"
    last_response.body.should == MultiJson.dump({ :meaning_of_life => 42 })
    last_response.headers["Cache-Control"].should == "private, max-age=0, must-revalidate"
    last_response.headers["Pragma"].should be_nil
    last_response.headers["Expires"].should == "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
