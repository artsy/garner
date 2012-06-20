require 'spec_helper'

describe Garner::Strategies::Keys::RequestPath do
  before :each do
    @request = Rack::Request.new({ "PATH_INFO" => "/foo" })
    @options = { :request => @request }
  end
  subject do
    Garner::Strategies::Keys::RequestPath
  end
  it "adds path" do
    subject.apply({}, @options).should eq({ :path => "/foo" })
    subject.apply({ :x => :y }, @options).should eq({ :x => :y, :path => "/foo" })
  end
end
