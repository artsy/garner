require "spec_helper"

describe Garner::Cache::Identity do

  it "includes Garner.config.global_cache_options" do
    Garner.configure { |config| config.global_cache_options = { :foo => "bar" } }
    subject.options_hash[:foo].should == "bar"
  end

  it "includes Garner.config.expires_in" do
    Garner.configure { |config| config.expires_in = 5.minutes }
    subject.options_hash[:expires_in].should == 5.minutes
  end

  describe "nocache" do
    it "forces a cache bypass" do
      Garner::Cache.should_not_receive :fetch
      subject.nocache.fetch { "foo" }
    end
  end

  describe "bind" do
    it "adds to the object identity's bindings" do
      subject.bind("foo")
      subject.bind("bar")
      subject.bindings.should == ["foo", "bar"]
    end

    it "raises an error for <> 1 arguments" do
      expect { subject.bind }.to raise_error
      expect { subject.bind("foo", "bar") }.to raise_error
    end
  end

  describe "key" do
    it "adds to the object identity's key_hash" do
      subject.key(:foo => 1)
      subject.key(:bar => 2)
      subject.key_hash.should == { :foo => 1, :bar => 2 }
    end

    it "raises an error for <> 1 arguments" do
      expect { subject.key }.to raise_error
      expect { subject.key({}, {}) }.to raise_error
    end

    it "raises an error for non-hash arguments" do
      expect { subject.key("foo") }.to raise_error
    end
  end

  describe "options" do
    it "adds to the object identity's options_hash" do
      subject.options(:foo => 1)
      subject.options(:bar => 2)
      subject.options_hash.should == { :expires_in => nil, :foo => 1, :bar => 2 }
    end

    it "raises an error for <> 1 arguments" do
      expect { subject.options }.to raise_error
      expect { subject.options({}, {}) }.to raise_error
    end

    it "raises an error for non-hash arguments" do
      expect { subject.options("foo") }.to raise_error
    end
  end
end
