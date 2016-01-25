require 'spec_helper'
require 'garner/mixins/mongoid'

describe Garner::Mixins::Mongoid::Identity do
  before(:each) do
    @mock_strategy = double('strategy')
    allow(@mock_strategy).to receive(:apply)
    @mock_mongoid_strategy = double('mongoid_strategy')
    allow(@mock_mongoid_strategy).to receive(:apply)
  end

  describe 'from_class_and_handle' do
    before(:each) do
      Garner.configure do |config|
        config.mongoid_identity_fields = [:_id, :_slugs]
      end
    end

    subject { Garner::Mixins::Mongoid::Identity }

    it 'raises an exception if called on a non-Mongoid class' do
      expect do
        subject.from_class_and_handle(Class.new, 'id')
      end.to raise_error

      expect do
        subject.from_class_and_handle(Monger.new, 'id')
      end.to raise_error
    end

    it 'raises an exception if called on an embedded document' do
      expect do
        subject.from_class_and_handle(Fish, 'id')
      end.to raise_error
    end

    it 'sets klass, handle and a conditions hash' do
      identity = subject.from_class_and_handle(Monger, 'id')
      expect(identity.klass).to eq Monger
      expect(identity.handle).to eq 'id'
      expect(identity.conditions['$or']).to eq [
        { _id: 'id' },
        { _slugs: 'id' }
      ]
    end

    context 'on a Mongoid subclass' do
      it 'sets klass to parent and includes the _type field' do
        identity = subject.from_class_and_handle(Cheese, 'id')
        expect(identity.klass).to eq Cheese
        expect(identity.conditions[:_type]).to eq('Cheese')
        expect(identity.conditions['$or']).to eq [
          { _id: 'id' },
          { _slugs: 'id' }
        ]
      end
    end
  end

  describe 'to_s' do
    subject { Monger.identify('m1').to_s }

    it 'stringizes the binding and includes klass and handle' do
      expect(subject).to be_a(String)
      expect(subject).to match(/Monger/)
      expect(subject).to match(/m1/)
    end

    it 'should not change across identical instances' do
      expect(subject).to eq Monger.identify('m1').to_s
    end

    it 'should be different across different instances' do
      expect(subject).not_to eq(Monger.identify('m2').to_s)
    end
  end

  context 'with default configuration and real documents' do
    before(:each) do
      Garner.configure do |config|
        config.mongoid_identity_fields = [:_id, :_slugs]
      end

      @monger = Monger.create(name: 'M1')
      @monger.reload
      @cheese = Cheese.create(name: 'Havarti')
      @cheese.reload
    end

    describe 'proxy_binding' do
      it 'returns nil for nonexistent bindings' do
        expect(Monger.identify('m2').proxy_binding).to be_nil
      end

      it 'returns nil for nil bindings' do
        @monger.unset(:_slugs)
        expect(Monger.identify(nil).proxy_binding).to be_nil
      end

      it 'limits the query' do
        expect_any_instance_of(Mongoid::Slug::Criteria).to receive(:limit).with(1).and_return([@monger])
        Monger.identify('m1').proxy_binding
      end

      describe 'cache_key' do
        it "generates a cache key equal to Mongoid::Document's" do
          expect(Monger.identify('m1').proxy_binding.cache_key).to eq @monger.cache_key

          # Also test for Mongoid subclasses
          expect(Cheese.identify('havarti').proxy_binding.cache_key).to eq @cheese.cache_key
          expect(Food.identify(@cheese.id).proxy_binding.cache_key).to eq @cheese.cache_key
        end

        context 'without Mongoid::Timestamps' do
          before(:each) do
            @monger.unset(:updated_at)
            @cheese.unset(:updated_at)
          end

          it "generates a cache key equal to Mongoid::Document's" do
            expect(Monger.identify('m1').proxy_binding.cache_key).to eq @monger.cache_key

            # Also test for Mongoid subclasses
            expect(Cheese.identify('havarti').proxy_binding.cache_key).to eq @cheese.cache_key
            expect(Food.identify(@cheese.id).proxy_binding.cache_key).to eq @cheese.cache_key
          end
        end
      end

      describe 'updated_at' do
        it "returns :updated_at equal to Mongoid::Document's" do
          expect(Monger.identify('m1').proxy_binding.updated_at).to eq Monger.find('m1').updated_at

          # Also test for Mongoid subclasses
          expect(Cheese.identify('havarti').proxy_binding.updated_at).to eq @cheese.updated_at
          expect(Food.identify(@cheese.id).proxy_binding.updated_at).to eq @cheese.updated_at
        end
      end
    end
  end
end
