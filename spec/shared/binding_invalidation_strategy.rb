# Shared examples for binding invalidation strategies. A valid strategy must
# implement:
#     # Invalidate an object binding.
#     #
#     # @param binding [Object] The object from which to compute a key.
#     def apply(binding)
#     end
shared_examples_for "Garner::Strategies::BindingInvalidation strategy" do
  it "requires an argument" do
    expect { subject.apply }.to raise_error
  end
end
