require "spec_helper"

describe Garner::Strategies::ContextKey::RequestPost do
  before(:each) do
    @cache_identity = Garner::Cache::Identity.new
    @request = Rack::Request.new(
      Rack::MockRequest.env_for(
        "/?foo=quux",
        "REQUEST_METHOD" => "POST",
        :input => "foo=bar"
      )
    )

    @mock_context = double "object"
    @mock_context.stub(:request) { @request }
  end

  it_behaves_like "Garner::Strategies::ContextKey strategy"

  it "adds :request_params to the key" do
    subject.apply(@cache_identity, @mock_context)
    @cache_identity.key_hash[:request_params].should == { "foo" => "bar" }
  end

  it "appends to an existing key hash" do
    @cache_identity.key({ :x => :y })
    subject.apply(@cache_identity, @mock_context).key_hash.should == {
      :x => :y,
      :request_params => { "foo" => "bar" }
    }
  end
end
