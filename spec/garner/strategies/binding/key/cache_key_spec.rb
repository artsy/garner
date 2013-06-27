require "spec_helper"

describe Garner::Strategies::Binding::Key::CacheKey do

  before(:each) do
    @mock = double("model")
    @mock.stub(:cache_key) { "mocks/4" }
  end

  subject { Garner::Strategies::Binding::Key::CacheKey }

  it_behaves_like "Garner::Strategies::Binding::Key strategy" do
    let(:known_bindings) { [@mock] }
    let(:unknown_bindings) { [@mock.class] }
  end

  describe "apply" do
    it "returns the object's cache key, or nil" do
      subject.apply(@mock).should == "mocks/4"
    end
  end

  context "with real objects" do
    it_behaves_like "Garner::Strategies::Binding::Key strategy" do
      let(:known_bindings) { [Activist.create, Monger.create] }
      let(:unknown_bindings) { [Monger.identify("m1"), Monger] }
    end
  end
end
