require 'spec_helper'

describe Garner::Keys::Strategies::RequestPath do
  before :each do
    @request = Rack::Request.new({ "PATH_INFO" => "/foo" })
    @options = { :request => @request }
  end
  it "adds path" do
    Garner::Keys::Strategies::RequestPath.apply({}, @options).should eq({ :path => "/foo" })
    Garner::Keys::Strategies::RequestPath.apply({ :x => :y }, @options).should eq({ :x => :y, :path => "/foo" })
  end
end
