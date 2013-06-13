# Shared examples for key strategies. A valid key strategy must implement
# apply(identity, ruby_context = self).
shared_examples_for "Garner::Strategies::Context::Key strategy" do
  before(:each) do
    @cache_identity = Garner::Cache::Identity.new
  end

  it "inherits from Garner::Strategies::Context::Key::Base" do
    subject.new.should be_a(Garner::Strategies::Context::Key::Base)
  end

  it "requires a Garner::Cache::Identity" do
    expect { subject.apply }.to raise_error
  end

  it "does not require an explicit context, defaulting to self" do
    expect { subject.apply(@cache_identity) }.to_not raise_error
  end

  it "returns a Garner::Cache::Identity" do
    modified_identity = subject.apply(@cache_identity, self)
    modified_identity.should == @cache_identity
  end
end
