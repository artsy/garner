# Shared examples for a proper Conditional GET server.
#   To test a new Rack framework, define an app returned by app, with a
#   single endpoint, "/".
shared_examples_for 'Rack::ConditionalGet server' do
  include Rack::Test::Methods

  def etag_for(body_str)
    Rack::ETag.new(nil).send(:digest_body, [body_str]).first
  end

  before(:each) do
    Garner.config.cache.clear
  end

  it "writes the cached object's ETag from binding" do
    get '/'
    expect(last_response.headers['ETag'].length).to eq 32 + 2 + 2
  end

  it 'sends a 304 response if content has not changed (If-None-Match)' do
    get '/'
    expect(last_response.status).to eq 200
    expect(last_response.headers['ETag']).to eq "W/\"#{etag_for(last_response.body)}\""
    get '/', {}, 'HTTP_IF_NONE_MATCH' => last_response.headers['ETag']
    expect(last_response.status).to eq 304
  end

  it 'sends a 200 response if content has changed (If-None-Match)' do
    get '/'
    expect(last_response.status).to eq 200
    get '/', {}, 'HTTP_IF_NONE_MATCH' => %("#{etag_for('foobar')}")
    expect(last_response.status).to eq 200
  end

  it 'sends a 200 response if content has changed (valid If-Modified-Since but invalid If-None-Match)' do
    get '/'
    expect(last_response.status).to eq 200
    get '/', {}, 'HTTP_IF_MODIFIED_SINCE' => (Time.now + 1).httpdate, 'HTTP_IF_NONE_MATCH' => etag_for(last_response.body)
    expect(last_response.status).to eq 200
  end

  it 'adds Cache-Control, Pragma and Expires headers' do
    get '/'
    expect(last_response.headers['Cache-Control'].split(', ').sort).to eq %w(max-age=0 must-revalidate private)
    expect(last_response.headers['Pragma']).to be_nil
    expect(Time.parse(last_response.headers['Expires'])).to be < Time.now
  end
end
