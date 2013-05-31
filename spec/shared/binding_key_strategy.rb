require "pry"
# Shared examples for binding strategies. A valid binding strategy must implement:
#     # Returns a cache key for this object.
#     #
#     # @param object [Object] The cache identity.
#     # @return [String] A cache key string.
#     def cache_key_for(object)
#     end
shared_examples_for "Garner::Strategies::BindingKey strategy" do
  it "requires an argument" do
    expect { subject.apply }.to raise_error
  end

  describe "given a serializable binding" do
    it "returns a valid cache key" do
      known_bindings.each do |binding|
        subject.apply(binding).should be_a(String)
      end
    end

    it "returns the same cache key for an unchanged object" do
      known_bindings.each do |binding|
        key1 = subject.apply(binding)
        key2 = subject.apply(binding)
        key1.should == key2
      end
    end
  end

  describe "given a non-serializable binding" do
    it "returns a nil cache key" do
      unknown_bindings.each do |binding|
        subject.apply(binding).should be_nil
      end
    end
  end
end
