require "spec_helper"

describe "ActiveRecord integration" do
  context "using the Garner::Strategies::Binding::Key::CacheKey strategy" do

    describe "cache key generation" do
      subject { Garner::Strategies::Binding::Key::CacheKey }

      it_behaves_like "Garner::Strategies::Binding::Key strategy" do
        let(:known_bindings) { [Activist.create, Activist.new] }
        let(:unknown_bindings) { [Activist] }
      end

      it "returns the object's cache key, or nil" do
        new_activist = Activist.new
        subject.apply(new_activist).should == "activists/new"

        persisted_activist = Activist.create
        timestamp = persisted_activist.updated_at.utc.to_s(:number)
        expected_key = "activists/#{persisted_activist.id}-#{timestamp}"
        subject.apply(persisted_activist).should == expected_key
      end
    end

    describe "garner_cache_key" do
      context "instance" do
        subject { Activist.create }

        it "returns a non-nil cache_key" do
          subject.garner_cache_key.should_not be_nil
        end
      end

      context "class" do
        subject { Activist }

        it "should not " do
          expect { subject.garner_cache_key }.not_to raise_error
        end
      end
    end
  end
end
