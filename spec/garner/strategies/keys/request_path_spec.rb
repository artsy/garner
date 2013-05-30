require "spec_helper"

describe Garner::Strategies::Keys::RequestPath do
  before(:each) do
    @cache_identity = Garner::Cache::Identity.new
    @request = Rack::Request.new({ "PATH_INFO" => "/foo" })

    @mock_context = double "object"
    @mock_context.stub(:request) { @request }
  end

  subject { Garner::Strategies::Keys::RequestPath }

  it_should_behave_like "Garner::Strategies::Keys strategy"

  it "adds :request_params to the key" do
    subject.apply(@cache_identity, @mock_context)
    @cache_identity.key_hash[:request_path].should == "/foo"
  end

  it "appends to an existing key hash" do
    @cache_identity.key({ :x => :y })
    subject.apply(@cache_identity, @mock_context).key_hash.should == {
      :x => :y,
      :request_path => "/foo"
    }
  end
end
