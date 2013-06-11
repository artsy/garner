# Shared examples for a proper Conditional GET server.
#   To test a new Rack framework, define an app returned by app, with a
#   single endpoint, "/".
shared_examples_for "Rack::ConditionalGet server" do
  include Rack::Test::Methods

  def etag_for(body_str)
    Rack::ETag.new(nil).send(:digest_body, [body_str]).first
  end

  before(:each) do
    Garner.config.cache.clear
  end

  it "writes the cached object's ETag from binding" do
    get "/"
    last_response.headers["ETag"].length.should == 32 + 2
  end

  it "sends a 304 response if content has not changed (If-None-Match)" do
    get "/"
    last_response.status.should == 200
    last_response.headers["ETag"].should == %Q{"#{etag_for(last_response.body)}"}
    get "/", {}, { "HTTP_IF_NONE_MATCH" => last_response.headers["ETag"] }
    last_response.status.should == 304
  end

  it "sends a 200 response if content has changed (If-None-Match)" do
    get "/"
    last_response.status.should == 200
    get "/", {}, { "HTTP_IF_NONE_MATCH" => %Q{"#{etag_for("foobar")}"} }
    last_response.status.should == 200
  end

  it "sends a 200 response if content has changed (valid If-Modified-Since but invalid If-None-Match)" do
    get "/"
    last_response.status.should == 200
    get "/", {}, { "HTTP_IF_MODIFIED_SINCE" => (Time.now + 1).httpdate, "HTTP_IF_NONE_MATCH" => %Q{"#{etag_for(last_response.body)}"} }
    last_response.status.should == 200
  end

  it "adds Cache-Control, Pragma and Expires headers" do
    get "/"
    last_response.headers["Cache-Control"].split(", ").sort.should == %w{max-age=0 must-revalidate private}
    last_response.headers["Pragma"].should be_nil
    Time.parse(last_response.headers["Expires"]).should be < Time.now
  end
end