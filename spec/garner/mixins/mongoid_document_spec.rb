require 'spec_helper'

describe Garner::Mixins::Mongoid::Document do
  describe "all_embedding_documents" do
    before :each do
      @foo = Foo.new
      @bar = Bar.new
      @foo.bar = @bar
      @baz = Baz.new
    end
    it "should not follow cycles in documents" do
      @bar.all_embedding_documents.should == [ @foo ]
    end
    it "should respect orphaned documents" do
      @baz.all_embedding_documents.should == []
      @baz.foo = Foo.new
      @baz.foo = nil
      @baz.all_embedding_documents.should == []
    end
  end
  describe "api_cache_class" do
    it "is used by :invalidate_api_cache" do
      t = TestModel.new
      t.stub(:metadata).and_return(nil)
      Garner::Cache::ObjectIdentity.stub(:invalidate).as_null_object
      Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModel, { :id => t.id })
      t.invalidate_api_cache
    end
    it "allows for an override" do
      TestModelChild.api_cache_class.should == TestModel
      t = TestModelChild.new
      t.stub(:metadata).and_return(nil)
      Garner::Cache::ObjectIdentity.stub(:invalidate).as_null_object
      Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModel, { :id => t.id })
      t.invalidate_api_cache
    end
    context "with mutliple identity fields" do
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
      it "invalidates only identity fields that exist" do
        t = TestModel.new
        t.stub(:metadata).and_return(nil)
        Garner::Cache::ObjectIdentity.stub(:invalidate).as_null_object
        Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModel, { :id => t.id })
        t.invalidate_api_cache
      end
      it "invalidates all identity fields" do
        t = TestModelWithSlug.new({ :slug => "forty-two" })
        t.stub(:metadata).and_return(nil)
        Garner::Cache::ObjectIdentity.stub(:invalidate).as_null_object
        Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModelWithSlug, { :id => t.id })
        Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModelWithSlug, { :slug => "forty-two" })
        t.invalidate_api_cache
      end
    end
    context "callbacks" do
      before do
        Mongoid.configure do |config|
          config.connect_to('garner_test')
        end
      end
      after do
        Mongoid.purge!
      end
      it "create" do
        Garner::Cache::ObjectIdentity.stub(:invalidate).as_null_object
        Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModel)
        TestModel.create!
      end
      context "with an instance" do
        before do
          @t = TestModel.create!
        end
        it "update" do
          Garner::Cache::ObjectIdentity.stub(:invalidate).as_null_object
          Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModel, { :id => @t.id })
          Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModel)
          @t.update_attributes!({ :x => "y" })
        end
        it "save! without changes" do
          Garner::Cache::ObjectIdentity.stub(:invalidate).as_null_object
          Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModel, { :id => @t.id })
          Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModel)
          @t.save!
        end
        it "destroy" do
          Garner::Cache::ObjectIdentity.stub(:invalidate).as_null_object
          Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModel, { :id => @t.id })
          Garner::Cache::ObjectIdentity.should_receive(:invalidate).with(TestModel)
          @t.destroy
        end
      end
    end
  end
end
