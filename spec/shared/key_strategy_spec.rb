require "spec_helper"

# Shared examples for key strategies. A valid key strategy must implement:
#     # Applies this key strategy to a cache identity, modifying its key_hash.
#     #
#     # @param identity [Garner::Cache::Identity] The cache identity.
#     # @param ruby_context [Binding] An optional Ruby context.
#     # @return [Garner::Cache::Identity] The modified identity.
#     def apply(identity, ruby_context = Kernel.binding)
#     end
# which both modifies a Garner::CacheIdentity and returns the identity.
shared_examples_for "Garner::Strategies::Keys strategy" do
  before(:each) do
    @cache_identity = Garner::Cache::Identity.new
  end

  it "requires a Garner::Cache::Identity" do
    expect { subject.apply }.to raise_error
  end

  it "does not require an explicit context, defaulting to Kernel.binding" do
    Kernel.should_receive(:binding)
    expect { subject.apply(@cache_identity) }.to_not raise_error
  end

  it "returns a Garner::Cache::Identity" do
    modified_identity = subject.apply(@cache_identity, Kernel.binding)
    modified_identity.should == @cache_identity
  end
end
