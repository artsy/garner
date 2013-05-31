require "spec_helper"
require "garner/mixins/mongoid_document"

describe "Mongoid integration" do
  before(:each) do
    class Monger
      include Mongoid::Document
    end
  end

  [
    Garner::Strategies::BindingKey::CacheKey
    # Garner::Strategies::BindingKey::IndexedIdentities,
    # Garner::Strategies::BindingKey::DeclaredIdentities
  ].each do |strategy|
    context "using the #{strategy} strategy" do
      describe "cache key generation" do
        subject { strategy }

        it_behaves_like "Garner::Strategies::BindingKey strategy" do
          let(:known_bindings) { [ Monger.create ] }
          let(:unknown_bindings) { [] }
        end
      end

      describe "end-to-end caching and invalidation" do
        it "invalidates on create"

        it "invalidates on update"

        it "invalidates on destroy"

        it "invalidates by explicit call to invalidate_garner_caches"

        it "does not invalidate results for other like-classed objects"

        context "with inheritance" do
          it "binds to the correct object"
        end

        context "with an embedded document" do
          it "binds to the correct object"
        end

        context "with multiple identity fields" do
          it "invalidates all identities"
        end

        context "binding at the class level" do
          it "invalidates on create"

          it "invalidates on update"

          it "invalidates on destroy"
        end
      end
    end
  end
end
