require 'spec_helper'

describe Garner::Keys::Strategies::RequestGet do
  before :each do
    @request = Rack::Request.new({ "QUERY_STRING" => "foo=bar" })
    @options = { :request => @request }
  end
  it "adds query params" do
    Garner::Keys::Strategies::RequestGet.apply({}, @options).should eq({ :params => { "foo" => "bar" } })
    Garner::Keys::Strategies::RequestGet.apply({ :x => :y }, @options).should eq({ :x => :y, :params => { "foo" => "bar" } })
  end
  it "doesn't trash existing params" do
    Garner::Keys::Strategies::RequestGet.apply({ :x => :y, :params => { "x" => "y" } }, @options).should eq(
      { :x => :y, :params => { "x" => "y", "foo" => "bar" } }
    )
  end
end
