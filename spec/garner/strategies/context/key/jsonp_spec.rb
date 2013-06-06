require "spec_helper"

describe Garner::Strategies::Context::Key::Jsonp do
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
    Garner::Strategies::Context::Key::Jsonp
  end

  it_behaves_like "Garner::Strategies::Context::Key strategy"

  it "removes JSONP params from the key hash" do
    get_applied = Garner::Strategies::Context::Key::RequestGet.apply(@cache_identity, @mock_context)
    subject.apply(get_applied, @mock_context)
    @cache_identity.key_hash[:request_params].should == {}
  end
end
