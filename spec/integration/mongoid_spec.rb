require "spec_helper"

describe "Mongoid integration" do
  [
    Garner::Strategies::Bindings::SingleIdentity,
    Garner::Strategies::Bindings::IndexedIdentities,
    Garner::Strategies::Bindings::DeclaredIdentities
  ].each do |strategy|
    context "using the #{strategy} strategy" do
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
