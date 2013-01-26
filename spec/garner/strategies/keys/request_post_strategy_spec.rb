require 'spec_helper'

describe Garner::Strategies::Keys::RequestPost do
  before :each do
    @request = Rack::Request.new Rack::MockRequest.env_for("/?foo=quux",
        "REQUEST_METHOD" => 'POST',
        :input => "foo=bar")
    @options = { :request => @request }
  end
  subject do
    Garner::Strategies::Keys::RequestPost
  end
  it "adds post params" do
    subject.apply({}, @options).should eq({ :params => { "foo" => "bar" } })
    subject.apply({ :x => :y }, @options).should eq({ :x => :y, :params => { "foo" => "bar" } })
  end
end
