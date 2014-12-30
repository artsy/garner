require 'spec_helper'

describe Garner::Strategies::Context::Key::RequestGet do
  %w(GET HEAD).each do |method|
    context method do
      before(:each) do
        @cache_identity = Garner::Cache::Identity.new
        @request = Rack::Request.new('REQUEST_METHOD' => method, 'QUERY_STRING' => 'foo=bar')

        @mock_context = double('object')
        allow(@mock_context).to receive(:request) { @request }
      end

      subject { Garner::Strategies::Context::Key::RequestGet }

      it_behaves_like 'Garner::Strategies::Context::Key strategy'

      it 'adds :request_params to the key' do
        subject.apply(@cache_identity, @mock_context)
        expect(@cache_identity.key_hash[:request_params]).to eq('foo' => 'bar')
      end

      it 'appends to an existing key hash' do
        @cache_identity.key(x: :y)
        expect(subject.apply(@cache_identity, @mock_context).key_hash).to eq(
          x: :y,
          request_params: { 'foo' => 'bar' }
        )
      end
    end
  end
end
