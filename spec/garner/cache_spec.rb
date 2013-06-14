require "spec_helper"

describe Garner::Cache do
  subject do
    Garner::Cache
  end

  describe "fetch" do
    it "requires bindings, a key hash, and an options hash" do
      expect { subject.fetch { "foo" } }.to raise_error
      expect { subject.fetch([]) { "foo" } }.to raise_error
      expect { subject.fetch([], {}) { "foo" } }.to raise_error
    end

    it "requires a block" do
      expect { subject.fetch([], {}, {}) }.to raise_error
    end

    it "does not cache nil results" do
      result1 = subject.fetch([], {}, {}) { nil }
      result2 = subject.fetch([], {}, {}) { "foo" }
      result3 = subject.fetch([], {}, {}) { "bar" }

      result1.should == nil
      result2.should == "foo"
      result3.should == "foo"
    end

    it "does not cache results with un-bindable bindings" do
      unbindable = double("object")
      unbindable.stub(:garner_cache_key) { nil }
      result1 = subject.fetch([unbindable], {}, {}) { "foo" }
      result2 = subject.fetch([unbindable], {}, {}) { "bar" }
      result1.should == "foo"
      result2.should == "bar"
    end
  end
end
