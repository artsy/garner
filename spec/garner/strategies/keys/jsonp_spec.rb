require "spec_helper"

describe Garner::Strategies::Keys::Jsonp do
  before(:each) do
    @cache_identity = Garner::Cache::Identity.new
    @request = Rack::Request.new({
      "REQUEST_METHOD" => "GET",
      "QUERY_STRING" => "callback=jQuery21435&_=34234"
    })

    @mock_context = double "object"
    @mock_context.stub(:request) { @request }
  end

  subject do
    Garner::Strategies::Keys::Jsonp
  end

  it_should_behave_like "Garner::Strategies::Keys strategy"

  it "removes JSONP params from the key hash" do
    subject.apply(Garner::Strategies::Keys::RequestGet.apply(@cache_identity, @mock_context), @mock_context)
    @cache_identity.key_hash[:request_params].should == {}
  end
end
