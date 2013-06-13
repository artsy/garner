# Shared examples for binding strategies. A valid binding strategy must implement
# apply(binding).
shared_examples_for "Garner::Strategies::Binding::Key strategy" do
  it "requires an argument" do
    expect { subject.apply }.to raise_error
  end

  it "inherits from Garner::Strategies::Binding::Key::Base" do
    subject.new.should be_a(Garner::Strategies::Binding::Key::Base)
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
