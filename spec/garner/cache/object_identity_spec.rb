require 'spec_helper'

describe Garner::Cache::ObjectIdentity do
  subject do
    Garner::Cache::ObjectIdentity
  end
  before :each do
    subject.identity_fields = [ :slug, :id ]        
  end
  after :each do
    subject.identity_fields = nil
  end
  context "apply" do
    it "nil" do
      subject.send(:apply, nil).should eq({})
    end
    it "class and object with id" do
      subject.send(:apply, :bind => { :klass => Module, :object => { :id => 42 } }).should eq({
        :bind => { :klass => Module, :object => { :id => 42 } }
      })
    end
    it "class" do
      subject.send(:apply, :bind => { :klass => Module }).should eq({
        :bind => { :klass => Module }
      })
    end
    it "class and class with object with id" do
      subject.send(:apply, :bind => [{ :klass => Module }, { :klass => Class, :object => { :id => 42 } }]).should eq({
        :bind => [{ :klass => Module }, { :klass => Class, :object => { :id => 42 } }]
      })
    end
    context "shorthands" do
      it "array of type" do
        subject.send(:apply, :bind => [Module]).should eq({ :bind => { :klass => Module } })
      end
      it "array of type and id" do
        subject.send(:apply, :bind => [Module, 42]).should eq({ 
          :bind => { :klass => Module, :object => { :slug => 42 } }
        })
      end
      it "array of types" do
        subject.send(:apply, :bind => [[Module], [Class, { :id => 42 }]]).should eq({
          :bind => [{ :klass => Module }, { :klass => Class, :object => { :id => 42 }}]
        })
      end
    end
  end
  context "key" do
    it "nil" do
      lambda { subject.send(:key, nil) }.should raise_error(ArgumentError, "you cannot key nil")
    end
    it "generates an MD5 pair for class and object with id" do
      key_pair = subject.send(:key, :bind => { :klass => Module, :object => { :id => 42 } }).split(":")
      key_pair.length.should == 2
      key_pair[0].length.should == 32 # MD5
      key_pair[0].length.should == key_pair[1].length
    end
    it "generates the same key twice" do
      key1 = subject.send(:key, :bind => { :klass => Module, :object => { :id => 42 } })
      key2 = subject.send(:key, :bind => { :klass => Module, :object => { :id => 42 } })
      key1.should == key2
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
      key = subject.send(:key, {
        :bind => { :klass => Module, :object => { :id => 42 } },
        :version => "v1",
        :path => "method",
        :params => { "param1" => "arg1" }
      })
      prefix = subject.send(:find_or_create_key_prefix_for, Module, { :id => 42 })
      digest = Digest::MD5.hexdigest("v1\nmethod\n{\"param1\"=>\"arg1\"}")
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
      subject.send(:index, Class).should == { klass: Class }
    end
    it "should convert class-and-slug calls appropriately" do
      subject.send(:index, Class, "slug").should == { klass: Class, object: { slug: "slug" } }
    end
    it "should convert class-and-id calls appropriately" do
      subject.send(:index, Module, { id: 42 }).should == { klass: Module, object: { id: 42 } }
    end
  end
  context "index_string_for" do
    it "should generate correct index strings for class-bound objects" do
      subject.send(:index_string_for, Class).should == "INDEX:Class/*"
    end
    it "should generate correct index strings for object-bound (:slug) objects" do
      subject.send(:index_string_for, Class, { slug: "some-slug" }).should == "INDEX:Class/slug=some-slug"
    end
    it "should generate correct index strings for object-bound (:id) objects" do
      subject.send(:index_string_for, Class, { id: 42 }).should == "INDEX:Class/id=42"
    end
  end
  
=begin
  
  describe "cache" do

    it "caches values across calls" do
      r1 = ApiCache::cache(version: "v1", path: "method") { "one" }
      r2 = ApiCache::cache(version: "v1", path: "method") { "two" }
      [r1, r2].should == [ "one", "one" ]
    end

    it "caches values across calls with params" do
      r1 = ApiCache::cache(version: "v1", path: "method", params: { "name" => "value" }) { "one" }
      r2 = ApiCache::cache(version: "v1", path: "method", params: { "name" => "value" }) { "two" }
      [r1, r2].should == [ "one", "one" ]
    end

    it "makes a cache miss when force_miss=true" do
      r1 = ApiCache::cache(version: "v1", path:  "method", params: {}, cache_options: { force: true }) { "one" }
      r2 = ApiCache::cache(version: "v1", path:  "method", params: {}, cache_options: { force: true }) { "two" }
      [r1, r2].should == [ "one", "two" ]
    end

    it "makes a cache miss when params change" do
      r1 = ApiCache::cache(version: "v1", path: "method", params: {}) { "one" }
      r2 = ApiCache::cache(version: "v1", path: "method", params: {"name" => "value"}) { "two" }
      [r1, r2].should == [ "one", "two" ]
    end

    it "caches different values for different versions" do
      r1 = ApiCache::cache(version: "v1", path: "method") { "one" }
      r2 = ApiCache::cache(version: "v2", path: "method") { "two" }
      [r1, r2].should == [ "one", "two" ]
    end
    
    it "does not cache nil results" do
      r1 = ApiCache::cache(version: "v1", path: "method") { Class.first }
      Class = Fabricate(:Class)
      r2 = ApiCache::cache(version: "v1", path: "method") { Class.first }
      [r1, r2].should == [ nil, Class ]
    end
    
  end
  
  describe "invalidate" do
    it "invalidates klass-bound results when a klass is invalidated" do
      r1 = ApiCache::cache(bind: { klass: Class }) { "one" }
      r2 = ApiCache::cache(bind: { klass: Class }) { "one" }
      ApiCache::invalidate(klass: Class)
      r3 = ApiCache::cache(bind: { klass: Class }) { "two" }
      [r1, r2, r3].should == [ "one", "one", "two" ]
    end

    it "invalidates klass-bound results when any member of a klass is invalidated" do
      r1 = ApiCache::cache(bind: { klass: Class }) { "one" }
      r2 = ApiCache::cache(bind: { klass: Class }) { "one" }
      ApiCache::invalidate(klass: Class, object: { slug: "slug" })
      r3 = ApiCache::cache(bind: { klass: Class }) { "two" }
      [r1, r2, r3].should == [ "one", "one", "two" ]
    end
    
    it "invalidates object-bound results" do
      r1 = ApiCache::cache(bind: { klass: Class, object: { slug: "slug" } }) { "one" }
      r2 = ApiCache::cache(bind: { klass: Class, object: { slug: "slug" } }) { "one" }
      ApiCache::invalidate(klass: Class, object: { slug: "slug" })
      r3 = ApiCache::cache(bind: { klass: Class, object: { slug: "slug" } }) { "two" }
      [r1, r2, r3].should == [ "one", "one", "two" ]
    end

    it "does NOT invalidate object-bound results for different objects in the same klass" do
      r1 = ApiCache::cache(bind: { klass: Class, object: { slug: "slug" } }) { "one" }
      ApiCache::invalidate(klass: Class, object: { slug: "otherslug" })
      r2 = ApiCache::cache(bind: { klass: Class, object: { slug: "slug" } }) { "two" }
      [r1, r2].should == [ "one", "one" ]
    end
    
    it "updates the key prefix for the given object" do
      key1 = ApiCache::find_or_create_key_prefix_for(Class, { slug: "slug" })
      key2 = ApiCache::find_or_create_key_prefix_for(Class, { slug: "slug" })
      ApiCache::invalidate(klass: Class, object: { slug: "slug" })
      key3 = ApiCache::find_or_create_key_prefix_for(Class, { slug: "slug" })
      key1.should == key2
      key2.should_not == key3
    end
    
    it "updates the key prefix for the given klass, even if an object is specified" do
      key1 = ApiCache::find_or_create_key_prefix_for(Class)
      key2 = ApiCache::find_or_create_key_prefix_for(Class)
      ApiCache::invalidate(klass: Class, object: { slug: "slug" })
      key3 = ApiCache::find_or_create_key_prefix_for(Class)
      key1.should == key2
      key2.should_not == key3
    end
  end
  
  
=end
end
