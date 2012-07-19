require 'spec_helper'

describe Garner::Strategies::Keys::Jsonp do
  before :each do
    @request = Rack::Request.new({ "QUERY_STRING" => "callback=jQuery21435&_=34234"})
    @options = { :request => @request }
  end
  subject do
    Garner::Strategies::Keys::Jsonp
  end
  it "adds path" do
    subject.apply(Garner::Strategies::Keys::RequestGet.apply({}, @options)).should eq(:params => {})
  end
end
