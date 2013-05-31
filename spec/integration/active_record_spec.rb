require "spec_helper"

describe "ActiveRecord integration" do
  before(:each) do
    class Activist < ActiveRecord::Base
    end
  end

  context "using the Garner::Strategies::BindingKey::CacheKey strategy" do

    describe "cache key generation" do
      subject { Garner::Strategies::BindingKey::CacheKey }

      it_behaves_like "Garner::Strategies::BindingKey strategy" do
        let(:known_bindings) { [ Activist.create, Activist.new ] }
        let(:unknown_bindings) { [ Activist ] }
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
  end
end
