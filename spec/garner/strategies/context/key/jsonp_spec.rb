require "spec_helper"

describe Garner::Strategies::Context::Key::Jsonp do
  before(:each) do
    @cache_identity = Garner::Cache::Identity.new
    @request = Rack::Request.new({
      "REQUEST_METHOD" => "GET",
      "QUERY_STRING" => "callback=jQuery21435&_=34234"
    })

    @mock_context = double("object")
    @mock_context.stub(:request) { @request }
  end

  subject { Garner::Strategies::Context::Key::Jsonp }

  it_behaves_like "Garner::Strategies::Context::Key strategy"

  it "removes JSONP params from the key hash" do
    request_get = Garner::Strategies::Context::Key::RequestGet
    applied_identity = request_get.apply(@cache_identity, @mock_context)
    subject.apply(applied_identity, @mock_context)
    @cache_identity.key_hash[:request_params].should == {}
  end
end
