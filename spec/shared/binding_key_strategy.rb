# Shared examples for binding strategies. A valid binding strategy must implement:
#     # Compute a cache key from an object binding.
#     #
#     # @param binding [Object] The object from which to compute a key.
#     # @return [String] A cache key string.
#     def apply(binding)
#       binding.cache_key if binding.respond_to?(:cache_key)
#     end
shared_examples_for "Garner::Strategies::Binding::Key strategy" do
  it "requires an argument" do
    expect { subject.apply }.to raise_error
  end

  describe "given a known binding" do
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

  describe "given an unknown binding" do
    it "returns a nil cache key" do
      unknown_bindings.each do |binding|
        subject.apply(binding).should be_nil
      end
    end
  end
end
