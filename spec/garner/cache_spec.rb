require 'spec_helper'

describe Garner::Cache do
  subject do
    Garner::Cache
  end

  describe 'fetch' do
    it 'requires bindings, a key hash, and an options hash' do
      expect { subject.fetch { 'foo' } }.to raise_error
      expect { subject.fetch([]) { 'foo' } }.to raise_error
      expect { subject.fetch([], {}) { 'foo' } }.to raise_error
    end

    it 'requires a block' do
      expect { subject.fetch([], {}, {}) }.to raise_error
    end

    it 'does not cache nil results' do
      result1 = subject.fetch([], {}, {}) { nil }
      result2 = subject.fetch([], {}, {}) { 'foo' }
      result3 = subject.fetch([], {}, {}) { 'bar' }

      result1.should.nil?
      result2.should eq 'foo'
      result3.should eq 'foo'
    end

    it 'does not cache results with un-bindable bindings' do
      unbindable = double('object')
      unbindable.stub(:garner_cache_key) { nil }
      result1 = subject.fetch([unbindable], {}, {}) { 'foo' }
      result2 = subject.fetch([unbindable], {}, {}) { 'bar' }
      result1.should eq 'foo'
      result2.should eq 'bar'
    end

    it 'raises an exception by default for nil bindings' do
      expect do
        subject.fetch([nil], {}, {}) { 'foo' }
      end.to raise_error(Garner::Cache::NilBinding)
    end

    it 'raises no exception for nil bindings if config.whiny_nils is false' do
      Garner.configure { |config| config.whiny_nils = false }
      expect { subject.fetch([nil], {}, {}) { 'foo' } }.not_to raise_error
    end

    it 'deletes record when cached block yields nil' do
      binding = double('object', garner_cache_key: 'key')
      expect(Garner.config.cache).to receive(:delete).with({ binding_keys: ['key'], context_keys: { key: 'value' } }, { namespace: 'foo' })
      subject.fetch [binding], { key: 'value' }, namespace: 'foo' do
        nil
      end
    end
  end
end
