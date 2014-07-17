require 'spec_helper'
require 'garner/mixins/mongoid'

describe Garner::Mixins::Mongoid::Identity do
  before(:each) do
    @mock_strategy = double('strategy')
    @mock_strategy.stub(:apply)
    @mock_mongoid_strategy = double('mongoid_strategy')
    @mock_mongoid_strategy.stub(:apply)
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
      identity.klass.should eq Monger
      identity.handle.should eq 'id'
      identity.conditions['$or'].should eq [
        { _id: 'id' },
        { _slugs: 'id' }
      ]
    end

    context 'on a Mongoid subclass' do
      it 'sets klass to parent and includes the _type field' do
        identity = subject.from_class_and_handle(Cheese, 'id')
        identity.klass.should eq Cheese
        identity.conditions[:_type].should eq('$in' => ['Cheese'])
        identity.conditions['$or'].should eq [
          { _id: 'id' },
          { _slugs: 'id' }
        ]
      end
    end
  end

  describe 'to_s' do
    subject { Monger.identify('m1').to_s }

    it 'stringizes the binding and includes klass and handle' do
      subject.should be_a(String)
      subject.should =~ /Monger/
      subject.should =~ /m1/
    end

    it 'should not change across identical instances' do
      subject.should eq Monger.identify('m1').to_s
    end

    it 'should be different across different instances' do
      subject.should_not == Monger.identify('m2').to_s
    end
  end

  context 'with default configuration and real documents' do
    before(:each) do
      Garner.configure do |config|
        config.mongoid_identity_fields = [:_id, :_slugs]
      end

      @monger = Monger.create(name: 'M1')
      @cheese = Cheese.create(name: 'Havarti')
      @cheese.reload
    end

    describe 'proxy_binding' do
      it 'returns nil for nonexistent bindings' do
        Monger.identify('m2').proxy_binding.should be_nil
      end

      it 'returns nil for nil bindings' do
        @monger.unset(:_slugs)
        Monger.identify(nil).proxy_binding.should be_nil
      end

      it 'limits the query' do
        Mongoid::Slug::Criteria.any_instance.should_receive(:limit).with(1).and_return([@monger])
        Monger.identify('m1').proxy_binding
      end

      describe 'cache_key' do
        it "generates a cache key equal to Mongoid::Document's" do
          Monger.identify('m1').proxy_binding.cache_key.should eq @monger.cache_key

          # Also test for Mongoid subclasses
          Cheese.identify('havarti').proxy_binding.cache_key.should eq @cheese.cache_key
          Food.identify(@cheese.id).proxy_binding.cache_key.should eq @cheese.cache_key
        end

        context 'without Mongoid::Timestamps' do
          before(:each) do
            @monger.unset(:updated_at)
            @cheese.unset(:updated_at)
          end

          it "generates a cache key equal to Mongoid::Document's" do
            Monger.identify('m1').proxy_binding.cache_key.should eq @monger.cache_key

            # Also test for Mongoid subclasses
            Cheese.identify('havarti').proxy_binding.cache_key.should eq @cheese.cache_key
            Food.identify(@cheese.id).proxy_binding.cache_key.should eq @cheese.cache_key
          end
        end
      end

      describe 'updated_at' do
        it "returns :updated_at equal to Mongoid::Document's" do
          Monger.identify('m1').proxy_binding.updated_at.should eq Monger.find('m1').updated_at

          # Also test for Mongoid subclasses
          Cheese.identify('havarti').proxy_binding.updated_at.should eq @cheese.updated_at
          Food.identify(@cheese.id).proxy_binding.updated_at.should eq @cheese.updated_at
        end
      end
    end
  end
end
