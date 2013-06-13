# Shared examples for binding invalidation strategies. A valid strategy must
# implement apply(binding) and force_apply(binding)
shared_examples_for "Garner::Strategies::Binding::Invalidation strategy" do
  describe "apply" do
    it "requires an argument" do
      expect { subject.apply }.to raise_error
    end

    it "operates on any binding" do
      expect { subject.apply(double("foo")) }.not_to raise_error
    end
  end
end
