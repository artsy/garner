require 'spec_helper'

describe Garner::Strategies::Keys::RequestGet do
  before :each do
    @request = Rack::Request.new({ "QUERY_STRING" => "foo=bar" })
    @options = { :request => @request }
  end
  it "adds query params" do
    Garner::Strategies::Keys::RequestGet.apply({}, @options).should eq({ :params => { "foo" => "bar" } })
    Garner::Strategies::Keys::RequestGet.apply({ :x => :y }, @options).should eq({ :x => :y, :params => { "foo" => "bar" } })
  end
  it "doesn't trash existing params" do
    Garner::Strategies::Keys::RequestGet.apply({ :x => :y, :params => { "x" => "y" } }, @options).should eq(
      { :x => :y, :params => { "x" => "y", "foo" => "bar" } }
    )
  end
end
