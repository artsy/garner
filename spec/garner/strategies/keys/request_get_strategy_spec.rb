require 'spec_helper'

describe Garner::Strategies::Keys::RequestGet do
  before :each do
    @request = Rack::Request.new({ "QUERY_STRING" => "foo=bar" })
    @options = { :request => @request }
  end
  subject do
    Garner::Strategies::Keys::RequestGet
  end
  it "adds query params" do
    subject.apply({}, @options).should eq({ :params => { "foo" => "bar" } })
    subject.apply({ :x => :y }, @options).should eq({ :x => :y, :params => { "foo" => "bar" } })
  end
end
