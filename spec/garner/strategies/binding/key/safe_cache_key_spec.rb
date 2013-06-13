require "spec_helper"

describe Garner::Strategies::Binding::Key::SafeCacheKey do

  before(:each) do
    @mock = double "model"
    @mock.stub(:cache_key) { "mocks/4" }
  end

  it_behaves_like "Garner::Strategies::Binding::Key strategy" do
    let(:known_bindings) { [@mock] }
    let(:unknown_bindings) { [@mock.class] }
  end

  it "returns the object's safe cache key if defined" do
    @mock.stub(:safe_cache_key) { nil }
    subject.apply(@mock).should == nil
  end

  it "returns the object's cache key if defined" do
    subject.apply(@mock).should == "mocks/4"
  end

  it "returns nil otherwise" do
    @mock.unstub(:cache_key)
    subject.apply(@mock).should == nil
  end
end
