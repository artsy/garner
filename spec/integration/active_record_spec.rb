require 'spec_helper'

describe 'ActiveRecord integration', type: :request do
  context 'using the Garner::Strategies::Binding::Key::CacheKey strategy' do
    describe 'cache key generation' do
      subject { Garner::Strategies::Binding::Key::CacheKey }

      it_behaves_like 'Garner::Strategies::Binding::Key strategy' do
        let(:known_bindings) { [Activist.create, Activist.new] }
        let(:unknown_bindings) { [Activist] }
      end

      it "returns the object's cache key, or nil" do
        new_activist = Activist.new
        expect(subject.apply(new_activist)).to eq 'activists/new'

        persisted_activist = Activist.create
        timestamp = persisted_activist.updated_at.utc.to_s(persisted_activist.cache_timestamp_format)
        expected_key = "activists/#{persisted_activist.id}-#{timestamp}"
        expect(subject.apply(persisted_activist)).to eq expected_key
      end
    end

    describe 'garner_cache_key' do
      context 'instance' do
        subject { Activist.create }

        it 'returns a non-nil cache_key' do
          expect(subject.garner_cache_key).not_to be_nil
        end
      end

      context 'class' do
        subject { Activist }

        it 'should not ' do
          expect { subject.garner_cache_key }.not_to raise_error
        end
      end
    end
  end
end
