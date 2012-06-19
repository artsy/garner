require 'spec_helper'

describe Garner::Strategies::Keys::RequestPath do
  before :each do
    @request = Rack::Request.new({ "PATH_INFO" => "/foo" })
    @options = { :request => @request }
  end
  it "adds path" do
    Garner::Strategies::Keys::RequestPath.apply({}, @options).should eq({ :path => "/foo" })
    Garner::Strategies::Keys::RequestPath.apply({ :x => :y }, @options).should eq({ :x => :y, :path => "/foo" })
  end
end
