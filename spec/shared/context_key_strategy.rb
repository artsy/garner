# Shared examples for key strategies. A valid key strategy must implement:
#     # Applies this key strategy to a cache identity, modifying its key_hash.
#     #
#     # @param identity [Garner::Cache::Identity] The cache identity.
#     # @param ruby_context [Object] An optional Ruby context.
#     # @return [Garner::Cache::Identity] The modified identity.
#     def apply(identity, ruby_context = self)
#     end
# which both modifies a Garner::CacheIdentity and returns the identity.
shared_examples_for "Garner::Strategies::Context::Key strategy" do
  before(:each) do
    @cache_identity = Garner::Cache::Identity.new
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
