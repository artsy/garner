require 'spec_helper'

describe Garner::Cache::Identity do
  context 'with global_cache_options defined' do
    before do
      Garner.configure { |config| config.global_cache_options = { foo: 'bar' } }
    end

    it 'includes Garner.config.global_cache_options' do
      expect(subject.options_hash[:foo]).to eq 'bar'
    end
  end

  context 'with global_cache_options[:expires_in] defined ' do
    before do
      Garner.configure do |config|
        config.global_cache_options = { expires_in: 5.minutes }
      end
    end

    it 'includes Garner.config.global_cache_options[:expires_in]' do
      expect(subject.options_hash[:expires_in]).to eq 5.minutes
    end
  end

  context 'with config.expires_in defined' do
    before do
      Garner.configure { |config| config.expires_in = 5.minutes }
    end

    it 'includes Garner.config.expires_in' do
      expect(subject.options_hash[:expires_in]).to eq 5.minutes
    end
  end

  describe 'nocache' do
    it 'forces a cache bypass' do
      expect(Garner::Cache).not_to receive :fetch
      subject.nocache.fetch { 'foo' }
    end
  end

  describe 'bind' do
    it "adds to the object identity's bindings" do
      subject.bind('foo')
      subject.bind('bar')
      expect(subject.bindings).to eq %w(foo bar)
    end

    it 'raises an error for <> 1 arguments' do
      expect { subject.bind }.to raise_error
      expect { subject.bind('foo', 'bar') }.to raise_error
    end
  end

  describe 'key' do
    it "adds to the object identity's key_hash" do
      subject.key(foo: 1)
      subject.key(bar: 2)
      expect(subject.key_hash).to eq(foo: 1, bar: 2)
    end

    it 'raises an error for <> 1 arguments' do
      expect { subject.key }.to raise_error
      expect { subject.key({}, {}) }.to raise_error
    end

    it 'raises an error for non-hash arguments' do
      expect { subject.key('foo') }.to raise_error
    end
  end

  describe 'options' do
    it "adds to the object identity's options_hash" do
      subject.options(foo: 1)
      subject.options(bar: 2)
      expect(subject.options_hash).to eq(expires_in: nil, foo: 1, bar: 2)
    end

    it 'raises an error for <> 1 arguments' do
      expect { subject.options }.to raise_error
      expect { subject.options({}, {}) }.to raise_error
    end

    it 'raises an error for non-hash arguments' do
      expect { subject.options('foo') }.to raise_error
    end
  end
end
