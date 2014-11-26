require 'spec_helper'
require 'garner/mixins/mongoid'

describe Garner::Mixins::Mongoid::Document do
  context 'at the instance level' do
    before(:each) do
      Garner.configure do |config|
        config.mongoid_identity_fields = [:_id, :_slugs]
      end

      @monger = Monger.create(name: 'M1')
      @cheese = Cheese.create(name: 'M1')
    end

    describe 'proxied_classes' do
      it 'returns all Mongoid superclasses' do
        expect(@monger.proxied_classes).to eq [Monger]
        expect(@cheese.proxied_classes).to eq [Cheese, Food]
      end
    end
  end

  context 'at the class level' do
    subject { Monger }

    describe '_latest_by_updated_at' do
      it 'returns a Mongoid::Document instance' do
        subject.create
        expect(subject.send(:_latest_by_updated_at)).to be_a(subject)
      end

      it 'returns the _latest_by_updated_at document by :updated_at' do
        mongers = 3.times.map { |i| subject.create(name: "M#{i}") }
        mongers[1].touch

        expect(subject.send(:_latest_by_updated_at)._id).to eq mongers[1]._id
        expect(subject.send(:_latest_by_updated_at).updated_at).to eq mongers[1].reload.updated_at
      end

      it 'returns nil if there are no documents' do
        expect(subject.send(:_latest_by_updated_at)).to be_nil
      end

      it 'returns nil if updated_at does not exist' do
        subject.create
        allow(subject).to receive(:fields) { {} }
        expect(subject.send(:_latest_by_updated_at)).to be_nil
      end
    end

    describe 'proxy_binding' do
      it 'returns the _latest_by_updated_at document' do
        subject.create
        expect(subject.proxy_binding).to be_a(Monger)
      end

      it 'responds to :touch' do
        subject.create
        expect_any_instance_of(subject).to receive(:touch)
        subject.proxy_binding.touch
      end

      describe 'cache_key' do
        it 'matches what would be returned from the full object' do
          monger = subject.create
          expect(subject.proxy_binding.cache_key).to eq monger.reload.cache_key
        end

        context 'with Mongoid subclasses' do
          subject { Cheese }

          it 'matches what would be returned from the full object' do
            cheese = subject.create
            expect(subject.proxy_binding.cache_key).to eq cheese.reload.cache_key
          end
        end
      end
    end
  end
end
