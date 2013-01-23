require 'spec_helper'

describe Garner::Cache::ObjectIdentity do
  subject do
    Garner::Cache::ObjectIdentity
  end
  before :each do
    silence_warnings do
      Garner::Cache::ObjectIdentity::IDENTITY_FIELDS = [ :slug, :id ]
    end
  end
  after :each do
    silence_warnings do
      Garner::Cache::ObjectIdentity::IDENTITY_FIELDS = [ :id ]
    end
  end
  context "standardize" do
    it "nil" do
      subject.send(:standardize, nil).should be_nil
    end
    it "class and object with id" do
      subject.send(:standardize, { :klass => Module, :object => { :id => 42 } }).should eq({
        :klass => Module, :object => { :id => 42 }
      })
    end
    it "class" do
      subject.send(:standardize, { :klass => Module }).should eq({
        :klass => Module
      })
    end
    it "class and class with object with id" do
      subject.send(:standardize, [{ :klass => Module }, { :klass => Class, :object => { :id => 42 } }]).should eq([
        { :klass => Module }, { :klass => Class, :object => { :id => 42 } }
      ])
    end
    context "shorthands" do
      it "array of type" do
        subject.send(:standardize, [Module]).should eq({ :klass => Module })
      end
      it "array of type and id" do
        subject.send(:standardize, [Module, 42]).should eq({
          :klass => Module, :object => { :slug => 42 }
        })
      end
      it "array of types" do
        subject.send(:standardize, [[Module], [Class, { :id => 42 }]]).should eq([
          { :klass => Module }, { :klass => Class, :object => { :id => 42 }}
        ])
      end
    end
  end
  context "key" do
    it "nil" do
      subject.send(:key, nil).should end_with ":#{Digest::MD5.hexdigest('')}"
    end
    it "generates an MD5 pair for class and object with id" do
      key_pair = subject.send(:key, :bind => { :klass => Module, :object => { :id => 42 } }).split(":")
      key_pair.length.should == 2
      key_pair[0].length.should == 32 # MD5
      key_pair[0].length.should == key_pair[1].length
    end
    it "generates a different key for different IDs" do
      key1 = subject.send(:key, :bind => { :klass => Module, :object => { :id => 42 } })
      key2 = subject.send(:key, :bind => { :klass => Module, :object => { :id => 24 } })
      key1.should_not == key2
    end
    it "standardizes shortcuts" do
      key1 = subject.send(:key, :bind => [Module])
      key2 = subject.send(:key, :bind => { :klass => Module })
      key1.should == key2
    end
    it "keys all parameters" do
      binding = { :bind => { :klass => Module, :object => { :id => 42 } } }
      options = {
        :version => "v1",
        :path => "method",
        :params => { "param1" => "arg1" }
      }
      key = subject.send(:key, binding, options)
      prefix = subject.send(:find_or_create_key_prefix_for, Module, { :id => 42 })
      digest = Digest::MD5.hexdigest([ "v1", "method", { "param1" => "arg1" }].join("\n"))
      key.should == "#{prefix}:#{digest}"
    end
    it "keys single klasses correctly" do
      key = subject.send(:key, :bind => { :klass => Module })
      prefix = subject.send(:find_or_create_key_prefix_for, Module)
      key.should == "#{prefix}:#{Digest::MD5.hexdigest('')}"
    end
    it "keys array args to :bind correctly" do
      key = subject.send(:key, :bind => [
        { :klass => Module },
        { :klass => Class, :object => { :id => 42 } },
        { :klass => Kernel, :object => { :slug => "dr-worm" } }
      ])
      prefix1 = subject.send(:find_or_create_key_prefix_for, Module)
      prefix2 = subject.send(:find_or_create_key_prefix_for, Class, { :id => 42 })
      prefix3 = subject.send(:find_or_create_key_prefix_for, Kernel, { :slug => "dr-worm" })
      key.should == "#{prefix1},#{prefix2},#{prefix3}:#{Digest::MD5.hexdigest('')}"
    end
  end
  context "index" do
    it "should convert class-only calls appropriately" do
      subject.send(:index, Class).should == { :klass => Class }
    end
    it "should convert class-and-slug calls appropriately" do
      subject.send(:index, Class, "slug").should == { :klass => Class, :object => { :slug => "slug" } }
    end
    it "should convert class-and-id calls appropriately" do
      subject.send(:index, Module, { :id => 42 }).should == { :klass => Module, :object => { :id => 42 } }
    end
  end
  context "index_string_for" do
    it "should generate correct index strings for class-bound objects" do
      subject.send(:index_string_for, Class).should == "INDEX:Class/*"
    end
    it "should generate correct index strings for object-bound (:slug) objects" do
      subject.send(:index_string_for, Class, { :slug => "some-slug" }).should == "INDEX:Class/slug=some-slug"
    end
    it "should generate correct index strings for object-bound (:id) objects" do
      subject.send(:index_string_for, Class, { :id => 42 }).should == "INDEX:Class/id=42"
    end
  end
  context "cached" do
    before :each do
      Garner.config.cache.clear
    end
    context "cache" do
      it "caches values across calls from different loc" do
        request = Rack::Request.new({ "PATH_INFO" => "method" })
        r1 = subject.cache(nil, { :version => "v1", :request => request }) { "one" }
        r2 = subject.cache(nil, { :version => "v1", :request => request }) { "two" }
        [r1, r2].should == [ "one", "two" ]
      end
      it "caches values across calls from the same loc" do
        request = Rack::Request.new({ "PATH_INFO" => "method" })
        context = { :version => "v1", :request => request }
        r1 = subject.cache(nil, context) { "one" }; r2 = subject.cache(nil, context) { "two" }
        [r1, r2].should == [ "one", "one" ]
      end
      context "noloc" do
        before :each do
          Garner::Strategies::Keys::Caller.stub(:apply) do |key, context|
            key
          end
        end
        it "caches values across calls with params" do
          request = Rack::Request.new({ "PATH_INFO" => "method", "QUERY_STRING" => "name=value" })
          context = { :version => "v1", :request => request }
          r1 = subject.cache(nil, context) { "one" }; r2 = subject.cache(nil, context) { "two" }
          [r1, r2].should == [ "one", "one" ]
        end
        it "makes a cache miss when force_miss=true" do
          request = Rack::Request.new({ "PATH_INFO" => "method" })
          r1 = subject.cache(nil, { :version => "v1", :request => request, :cache_options => { :force => true } }) { "one" }
          r2 = subject.cache(nil, { :version => "v1", :request => request, :cache_options => { :force => true } }) { "two" }
          [r1, r2].should == [ "one", "two" ]
        end
        it "makes a cache miss when params change" do
          request1 = Rack::Request.new({ "PATH_INFO" => "method" })
          request2 = Rack::Request.new({ "PATH_INFO" => "method", "QUERY_STRING" => "name=value" })
          r1 = subject.cache(nil, { :version => "v1", :request => request1 }) { "one" }
          r2 = subject.cache(nil, { :version => "v1", :request => request2 }) { "two" }
          [r1, r2].should == [ "one", "two" ]
        end
        it "caches different values for different versions" do
          request = Rack::Request.new({ "PATH_INFO" => "method" })
          r1 = subject.cache(nil, { :version => "v1", :request => request }) { "one" }
          r2 = subject.cache(nil, { :version => "v2", :request => request }) { "two" }
          [r1, r2].should == [ "one", "two" ]
        end
        it "does not cache nil results" do
          var = Object.new
          request = Rack::Request.new({ "PATH_INFO" => "method" })
          r1 = subject.cache(nil, { :version => "v1", :request => request }) { nil }
          r2 = subject.cache(nil, { :version => "v1", :request => request }) { var }
          [r1, r2].should == [ nil, var ]
        end
      end
    end
    context "invalidate" do
      before :each do
        Garner::Strategies::Keys::Caller.stub(:apply) do |key, context|
          key
        end
      end
      it "does not write new records to cache" do
        r1 = subject.cache(:bind => { :klass => Class }) { "one" }
        Garner.config.cache.should_not_receive(:write)
        subject.invalidate(:klass => Class)
      end
      it "invalidates klass-bound results when a klass is invalidated" do
        r1 = subject.cache(:bind => { :klass => Class }) { "one" }
        r2 = subject.cache(:bind => { :klass => Class }) { "one" }
        subject.invalidate(:klass => Class)
        r3 = subject.cache(:bind => { :klass => Class }) { "two" }
        [r1, r2, r3].should == [ "one", "one", "two" ]
      end
      it "invalidates klass-bound results when any member of a klass is invalidated" do
        r1 = subject.cache(:bind => { :klass => Class }) { "one" }
        r2 = subject.cache(:bind => { :klass => Class }) { "one" }
        subject.invalidate(:klass => Class, :object => { :slug => "slug" })
        r3 = subject.cache(:bind => { :klass => Class }) { "two" }
        [r1, r2, r3].should == [ "one", "one", "two" ]
      end
      it "invalidates object-bound results" do
        r1 = subject.cache(:bind => { :klass => Class, :object => { :slug => "slug" } }) { "one" }
        r2 = subject.cache(:bind => { :klass => Class, :object => { :slug => "slug" } }) { "one" }
        subject.invalidate(:klass => Class, :object => { :slug => "slug" })
        r3 = subject.cache(:bind => { :klass => Class, :object => { :slug => "slug" } }) { "two" }
        [r1, r2, r3].should == [ "one", "one", "two" ]
      end
      it "invalidates bound results with multiple bindings" do
        class OtherClass ; end
        r1 = subject.cache(:bind => [{ :klass => Class }, { :klass => OtherClass }]) { "one" }
        subject.invalidate(:klass => Class)
        r2 = subject.cache(:bind => [{ :klass => Class }, { :klass => OtherClass }]) { "two" }
        subject.invalidate(:klass => OtherClass)
        r3 = subject.cache(:bind => [{ :klass => Class }, { :klass => OtherClass }]) { "three" }
        [r1, r2, r3].should == [ "one", "two", "three" ]
      end
      it "does NOT invalidate object-bound results for different objects in the same klass" do
        r1 = subject.cache(:bind => { :klass => Class, :object => { :slug => "slug" } }) { "one" }
        subject.invalidate(:klass => Class, :object => { :slug => "otherslug" })
        r2 = subject.cache(:bind => { :klass => Class, :object => { :slug => "slug" } }) { "two" }
        [r1, r2].should == [ "one", "one" ]
      end
      it "updates the key prefix for the given object" do
        key1 = subject.send(:find_or_create_key_prefix_for, Class, { :slug => "slug" })
        key2 = subject.send(:find_or_create_key_prefix_for, Class, { :slug => "slug" })
        subject.invalidate(:klass => Class, :object => { :slug => "slug" })
        key3 = subject.send(:find_or_create_key_prefix_for, Class, { :slug => "slug" })
        key1.should == key2
        key2.should_not == key3
      end
      it "updates the key prefix for the given klass, even if an object is specified" do
        key1 = subject.send(:find_or_create_key_prefix_for, Class)
        key2 = subject.send(:find_or_create_key_prefix_for, Class)
        subject.invalidate(:klass => Class, :object => { :slug => "slug" })
        key3 = subject.send(:find_or_create_key_prefix_for, Class)
        key1.should == key2
        key2.should_not == key3
      end
    end
  end
  [ :dalli_store, :memory_store ].each do |cache_store|
    context "#{cache_store}" do
      before :each do
        @cache = Garner.config.cache
        Garner.config.cache = ActiveSupport::Cache.lookup_store(cache_store)
        Garner.config.cache.clear
        Garner::Strategies::Keys::Caller.stub(:apply) do |key, context|
          key
        end
      end
      after :each do
        Garner.config.cache = @cache
      end
      context "cache multiple bindings" do
        it "caches values across calls from different loc" do
          data = { "one" => 1, "two" => 2 }
          bindings = [ { :bind => [ Object, :id => "one" ]}, { :bind => [ Object, :id => "two" ]} ]
          2.times do
            result = subject.cache(bindings) do |binding|
              data[binding[:bind][1][:id]]
            end
            result.should == [ 1, 2 ]
          end
        end
      end
    end
    context "dalli_store" do
      before :each do
        @cache = Garner.config.cache
        Garner.config.cache = ActiveSupport::Cache.lookup_store(:dalli_store)
        Garner.config.cache.clear
        Garner::Strategies::Keys::Caller.stub(:apply) do |key, context|
          key
        end
      end
      after :each do
        Garner.config.cache = @cache
      end
      it "uses read_multi" do
        data = { "one" => 1, "two" => 2 }
        bindings = [ { :bind => [ Object, :id => "one" ]}, { :bind => [ Object, :id => "two" ]} ]
        # cache results
        result = subject.cache(bindings) do |binding|
          data[binding[:bind][1][:id]]
        end
        result = subject.cache(bindings) do |binding|
          raise "this should not be called, data is cached"
        end
      end
    end
  end
end
