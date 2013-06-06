describe Garner::Strategies::Binding::Key::CacheKey do

  before(:each) do
    @mock = double "model"
    @mock.stub(:cache_key) { "mocks/4" }
  end

  it_behaves_like "Garner::Strategies::Binding::Key strategy" do
    let(:known_bindings) { [ @mock ] }
    let(:unknown_bindings) { [ @mock.class ] }
  end

  it "returns the object's cache key, or nil" do
    subject.apply(@mock).should == "mocks/4"
  end
end
