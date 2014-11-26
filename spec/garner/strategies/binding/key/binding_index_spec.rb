require 'spec_helper'

describe Garner::Strategies::Binding::Key::BindingIndex do

  before(:each) do
    @new_mock = double('new_mock')

    @persisted_mock = double('persisted_mock')
    allow(@persisted_mock).to receive(:identity_string) { 'Mocker/id=4' }
    allow(@persisted_mock).to receive(:updated_at) { @time_dot_now }

    @persisted_mock_alias = double('persisted_mock_alias')
    allow(@persisted_mock_alias).to receive(:identity_string) { 'MockerAlias/id=alias-4' }
    allow(@persisted_mock_alias).to receive(:proxy_binding) { @persisted_mock }

    allow(subject).to receive(:canonical?) do |binding|
      binding == @persisted_mock
    end

    # Marshal.load will return a new mock object, breaking equivalence tests
    # when fetching from cache.
    load_method = Marshal.method(:load)
    allow(Marshal).to receive(:load) do |dump|
      default = load_method.call(dump)
      if default.is_a?(RSpec::Mocks::Double) &&
         default.instance_variable_get(:@name) == 'persisted_mock'
        @persisted_mock
      else
        default
      end
    end

    # Stub SecureRandom.hex()-generated keys for consistency.
    @mock_key = 'cc318d04bac07d5d91f06f8c'
    @mock_alias_key = 'f254b853d7b32406b5749410'
    @random_key = 'b1d44bb6b369903b28549271'
    allow(subject).to receive(:new_cache_key_for) do |binding|
      if binding == @persisted_mock
        @mock_key
      elsif binding == @persisted_mock_alias
        @mock_alias_key
      else
        SecureRandom.hex(12)
      end
    end
  end

  subject { Garner::Strategies::Binding::Key::BindingIndex }

  it_behaves_like 'Garner::Strategies::Binding::Key strategy' do
    let(:known_bindings) { [@persisted_mock, @persisted_mock_alias] }
    let(:unknown_bindings) { [] }
  end

  describe 'apply' do
    it 'calls fetch_cache_key_for' do
      expect(subject).to receive(:fetch_cache_key_for).with(@persisted_mock)
      subject.apply(@persisted_mock)
    end
  end

  describe 'fetch_cache_key_for' do
    context 'with a canonical binding' do
      it 'returns a cache key string' do
        expect(subject.fetch_cache_key_for(@persisted_mock)).to eq @mock_key
      end

      it 'stores the cache key to cache' do
        subject.fetch_cache_key_for(@persisted_mock)
        expect(Garner.config.cache.read(
                                   strategy: subject,
                                   proxied_binding: 'Mocker/id=4'
                                 )).to eq @mock_key
      end
    end

    context 'with a non-canonical binding' do
      it 'returns a cache key string' do
        expect(subject.fetch_cache_key_for(@persisted_mock_alias)).to eq @mock_key
      end

      it 'stores the canonical binding to cache' do
        subject.fetch_cache_key_for(@persisted_mock_alias)
        expect(Garner.config.cache.read(
                                   strategy: subject,
                                   proxied_binding: 'MockerAlias/id=alias-4'
                                 )).to eq @persisted_mock
      end

      it 'stores the cache key to cache' do
        subject.fetch_cache_key_for(@persisted_mock_alias)
        expect(Garner.config.cache.read(
                                   strategy: subject,
                                   proxied_binding: 'Mocker/id=4'
                                 )).to eq @mock_key
      end

      context 'whose canonical binding is nil' do
        before(:each) do
          allow(@persisted_mock_alias).to receive(:proxy_binding) { nil }
        end

        it 'returns a nil cache key' do
          expect(subject.fetch_cache_key_for(@persisted_mock_alias)).to be_nil
        end

        it 'does not store the cache key to cache' do
          subject.fetch_cache_key_for(@persisted_mock_alias)
          expect(Garner.config.cache.read(
                                     strategy: subject,
                                     proxied_binding: ''
                                   )).to be_nil
        end
      end
    end
  end

  describe 'write_cache_key_for' do
    context 'with a canonical binding' do
      it 'returns a cache key string' do
        expect(subject.write_cache_key_for(@persisted_mock)).to eq @mock_key
      end
    end

    context 'with a non-canonical binding' do
      it 'returns a cache key string' do
        expect(subject.write_cache_key_for(@persisted_mock_alias)).to eq @mock_key
      end

      context 'whose canonical binding is nil' do
        before(:each) do
          allow(@persisted_mock_alias).to receive(:proxy_binding) { nil }
        end

        it 'returns a nil cache key' do
          expect(subject.write_cache_key_for(@persisted_mock_alias)).to be_nil
        end
      end
    end
  end

  describe 'fetch_canonical_binding_for' do
    context 'with a canonical binding' do
      it 'returns the canonical binding' do
        expect(subject.fetch_canonical_binding_for(@persisted_mock)).to eq @persisted_mock
      end
    end

    context 'with a non-canonical binding' do
      it 'returns the canonical binding' do
        expect(subject.fetch_canonical_binding_for(@persisted_mock_alias)).to eq @persisted_mock
      end

      it 'stores the canonical binding to cache' do
        subject.fetch_canonical_binding_for(@persisted_mock_alias)
        expect(Garner.config.cache.read(
                                   strategy: subject,
                                   proxied_binding: 'MockerAlias/id=alias-4'
                                 )).to eq @persisted_mock
      end
    end

    context 'with a proxyless binding' do
      it 'returns nil' do
        expect(subject.fetch_canonical_binding_for(@new_mock)).to be nil
      end
    end
  end

  describe 'write_canonical_binding_for' do
    context 'with a canonical binding' do
      it 'returns the canonical binding' do
        expect(subject.write_canonical_binding_for(@persisted_mock)).to eq @persisted_mock
      end
    end

    context 'with a non-canonical binding' do
      it 'returns the canonical binding' do
        expect(subject.write_canonical_binding_for(@persisted_mock_alias)).to eq @persisted_mock
      end
    end

    context 'with a proxyless binding' do
      it 'returns nil' do
        expect(subject.write_canonical_binding_for(@new_mock)).to be nil
      end
    end
  end

  context 'with real objects' do
    before(:each) do
      allow(subject).to receive(:canonical?).and_call_original
      allow(subject).to receive(:new_cache_key_for).and_call_original
      Garner.configure do |config|
        config.mongoid_identity_fields = [:_id, :_slugs]
      end

      @cheese = Cheese.create(name: 'M1')
      @food = Food.create(name: 'F1')
    end

    it_behaves_like 'Garner::Strategies::Binding::Key strategy' do
      let(:known_bindings) do
        [Cheese, @cheese, Cheese.identify(@cheese.id), Cheese.identify('m1')]
      end

      let(:unknown_bindings) do
        [Cheese.identify('m2'), Food.identify(nil)]
      end
    end

    describe 'apply' do
      it 'retrieves the correct key' do
        key = subject.apply(Cheese.find('m1'))
        expect(subject.apply(Cheese.identify('m1'))).to eq key
      end

      it 'stores the appropriate values to cache' do
        key1 = subject.apply(Food.identify(@cheese.id))
        key2 = subject.apply(Cheese.identify('m1'))
        expect(key1).to eq key2

        expect(Garner.config.cache.read(
                                   strategy: subject,
                                   proxied_binding: "Garner::Mixins::Mongoid::Identity/klass=Food,handle=#{@cheese.id}"
                                 )).to eq @cheese

        expect(Garner.config.cache.read(
                                   strategy: subject,
                                   proxied_binding: 'Garner::Mixins::Mongoid::Identity/klass=Cheese,handle=m1'
                                 )).to eq @cheese

        expect(Garner.config.cache.read(
                                   strategy: subject,
                                   proxied_binding: "Cheese/id=#{@cheese.id}"
                                 )).to eq key1

        expect(Garner.config.cache.read(
                                   strategy: subject,
                                   proxied_binding: "Food/id=#{@cheese.id}"
                                 )).to be_nil
      end
    end
  end
end
