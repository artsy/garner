require "spec_helper"

describe Garner::Strategies::Binding::Key::BindingIndex do

  before(:each) do
    @new_mock = double("new_mock")

    @persisted_mock = double("persisted_mock")
    @persisted_mock.stub(:identity_string) { "Mocker/id=4" }
    @persisted_mock.stub(:updated_at) { @time_dot_now }

    @persisted_mock_alias = double("persisted_mock_alias")
    @persisted_mock_alias.stub(:identity_string) { "MockerAlias/id=alias-4" }
    @persisted_mock_alias.stub(:proxy_binding) { @persisted_mock }

    subject.stub(:canonical?) do |binding|
      binding == @persisted_mock
    end

    # Marshal.load will return a new mock object, breaking equivalence tests
    # when fetching from cache.
    _load = Marshal.method(:load)
    Marshal.stub(:load) do |dump|
      default = _load.call(dump)
      if default.is_a?(RSpec::Mocks::Mock) &&
         default.instance_variable_get(:@name) == "persisted_mock"
        @persisted_mock
      else
        default
      end
    end

    # Stub SecureRandom.hex()-generated keys for consistency.
    @mock_key = "cc318d04bac07d5d91f06f8c"
    @mock_alias_key = "f254b853d7b32406b5749410"
    @random_key = "b1d44bb6b369903b28549271"
    subject.stub(:new_cache_key_for) do |binding|
      if binding == @persisted_mock
        @mock_key
      elsif binding == @persisted_mock_alias
        @mock_alias_key
      else
        SecureRandom.hex(12)
      end
    end
  end

  subject { Garner::Strategies::Binding::Key::BindingIndex }

  it_behaves_like "Garner::Strategies::Binding::Key strategy" do
    let(:known_bindings) { [@persisted_mock, @persisted_mock_alias] }
    let(:unknown_bindings) { [] }
  end

  describe "apply" do
    it "calls fetch_cache_key_for" do
      subject.should_receive(:fetch_cache_key_for).with(@persisted_mock)
      subject.apply(@persisted_mock)
    end
  end

  describe "fetch_cache_key_for" do
    context "with a canonical binding" do
      it "returns a cache key string" do
        subject.fetch_cache_key_for(@persisted_mock).should == @mock_key
      end

      it "stores the cache key to cache" do
        subject.fetch_cache_key_for(@persisted_mock)
        Garner.config.cache.read({
          :strategy => subject,
          :proxied_binding => "Mocker/id=4"
        }).should == @mock_key
      end
    end

    context "with a non-canonical binding" do
      it "returns a cache key string" do
        subject.fetch_cache_key_for(@persisted_mock_alias).should == @mock_key
      end

      it "stores the canonical binding to cache" do
        subject.fetch_cache_key_for(@persisted_mock_alias)
        Garner.config.cache.read({
          :strategy => subject,
          :proxied_binding => "MockerAlias/id=alias-4"
        }).should == @persisted_mock
      end

      it "stores the cache key to cache" do
        subject.fetch_cache_key_for(@persisted_mock_alias)
        Garner.config.cache.read({
          :strategy => subject,
          :proxied_binding => "Mocker/id=4"
        }).should == @mock_key
      end

      context "whose canonical binding is nil" do
        before(:each) do
          @persisted_mock_alias.stub(:proxy_binding) { nil }
        end

        it "returns a nil cache key" do
          subject.fetch_cache_key_for(@persisted_mock_alias).should be_nil
        end

        it "does not store the cache key to cache" do
          subject.fetch_cache_key_for(@persisted_mock_alias)
          Garner.config.cache.read({
            :strategy => subject,
            :proxied_binding => ""
          }).should be_nil
        end
      end
    end
  end

  describe "write_cache_key_for" do
    context "with a canonical binding" do
      it "returns a cache key string" do
        subject.write_cache_key_for(@persisted_mock).should == @mock_key
      end
    end

    context "with a non-canonical binding" do
      it "returns a cache key string" do
        subject.write_cache_key_for(@persisted_mock_alias).should == @mock_key
      end

      context "whose canonical binding is nil" do
        before(:each) do
          @persisted_mock_alias.stub(:proxy_binding) { nil }
        end

        it "returns a nil cache key" do
          subject.write_cache_key_for(@persisted_mock_alias).should be_nil
        end
      end
    end
  end

  describe "fetch_canonical_binding_for" do
    context "with a canonical binding" do
      it "returns the canonical binding" do
        subject.fetch_canonical_binding_for(@persisted_mock).should == @persisted_mock
      end
    end

    context "with a non-canonical binding" do
      it "returns the canonical binding" do
        subject.fetch_canonical_binding_for(@persisted_mock_alias).should == @persisted_mock
      end

      it "stores the canonical binding to cache" do
        subject.fetch_canonical_binding_for(@persisted_mock_alias)
        Garner.config.cache.read({
          :strategy => subject,
          :proxied_binding => "MockerAlias/id=alias-4"
        }).should == @persisted_mock
      end
    end

    context "with a proxyless binding" do
      it "returns nil" do
        subject.fetch_canonical_binding_for(@new_mock).should == nil
      end
    end
  end

  describe "write_canonical_binding_for" do
    context "with a canonical binding" do
      it "returns the canonical binding" do
        subject.write_canonical_binding_for(@persisted_mock).should == @persisted_mock
      end
    end

    context "with a non-canonical binding" do
      it "returns the canonical binding" do
        subject.write_canonical_binding_for(@persisted_mock_alias).should == @persisted_mock
      end
    end

    context "with a proxyless binding" do
      it "returns nil" do
        subject.write_canonical_binding_for(@new_mock).should == nil
      end
    end
  end

  context "with real objects" do
    before(:each) do
      subject.unstub(:canonical?)
      subject.unstub(:new_cache_key_for)
      Garner.configure do |config|
        config.mongoid_identity_fields = [:_id, :_slugs]
      end

      @cheese = Cheese.create({ :name => "M1" })
    end

    it_behaves_like "Garner::Strategies::Binding::Key strategy" do
      let(:known_bindings) do
        document = Monger.create({ :name => "M1" })
        identity = Monger.identify("m1")
        [Monger, document, identity]
      end
      let(:unknown_bindings) { [] }
    end

    describe "apply" do
      it "retrieves the correct key" do
        key = subject.apply(Cheese.find("m1"))
        subject.apply(Cheese.identify("m1")).should == key
      end

      it "stores the appropriate values to cache" do
        key1 = subject.apply(Food.identify(@cheese.id))
        key2 = subject.apply(Cheese.identify("m1"))
        key1.should == key2

        Garner.config.cache.read({
          :strategy => subject,
          :proxied_binding => "Garner::Mixins::Mongoid::Identity/klass=Food,handle=#{@cheese.id}"
        }).should == @cheese

        Garner.config.cache.read({
          :strategy => subject,
          :proxied_binding => "Garner::Mixins::Mongoid::Identity/klass=Cheese,handle=m1"
        }).should == @cheese

        Garner.config.cache.read({
          :strategy => subject,
          :proxied_binding => "Cheese/id=#{@cheese.id}"
        }).should == key1

        Garner.config.cache.read({
          :strategy => subject,
          :proxied_binding => "Food/id=#{@cheese.id}"
        }).should be_nil
      end
    end
  end
end
