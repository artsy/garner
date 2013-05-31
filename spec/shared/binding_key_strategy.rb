require "pry"
# Shared examples for binding strategies. A valid binding strategy must implement:
#     # Returns a cache key for this object.
#     #
#     # @param object [Object] The cache identity.
#     # @return [String] A cache key string.
#     def cache_key_for(object)
#     end
shared_examples_for "Garner::Strategies::BindingKey strategy" do
  it "returns a valid cache key" do
    subject.apply(binding).should be_a(String)
  end

  it "returns the same cache key for an unchanged object" do
    subject.apply(binding).should == subject.apply(binding)
  end
end
