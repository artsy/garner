require 'spec_helper'

describe Garner::Mixins::Mongoid::Document do
  describe "all_embedding_documents" do
    before(:each) do
      class Foo
        include Mongoid::Document
        embeds_one :bars
        embedded_in :bar
      end
      class Bar
        include Mongoid::Document
        embedded_in :foo
      end
      @foo = Foo.new
      @bar = Bar.new
      @foo.bar = @bar
    end
    it "should not follow cycles in documents" do
      @bar.all_embedding_documents.should == [ @foo ]
    end
  end
  describe "api_cache_class" do
    before(:each) do
      class TestModel
        def self.before_save(* args)
        end
        def self.before_destroy(* args)
        end
        attr_accessor :id
        include Garner::Mixins::Mongoid::Document
      end
      class OtherModel ; end
    end
    it "is used by :invalidate_api_cache" do
      @test = TestModel.new
      @test.stub(:metadata) { nil }
      @test.id = 42
      Garner::Cache::ObjectIdentity.stub(:invalidate).as_null_object
      Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModel, { :id => 42 })
      @test.invalidate_api_cache
    end
    it "allows for an override" do
      class TestModel
        cache_as OtherModel
      end
      TestModel.api_cache_class.should == OtherModel
      @test = TestModel.new
      @test.stub(:metadata) { nil }
      @test.id = 42
      Garner::Cache::ObjectIdentity.stub(:invalidate).as_null_object
      Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(OtherModel, { :id => 42 })
      @test.invalidate_api_cache
    end
  end
end
