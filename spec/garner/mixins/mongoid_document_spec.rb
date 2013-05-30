require "spec_helper"
require "garner/mixins/mongoid_document"

describe Garner::Mixins::Mongoid::Document do
  before(:each) do
    module Mongoid
      module Document
        include Garner::Mixins::Mongoid::Document
      end
    end
  end

  context "with a Mongoid document model" do
    subject do
      class TestModel
        include Mongoid::Document
      end
      TestModel
    end

    it "returns a valid index key for the class" do
      subject.garner_index_key.should == "TestModel"
    end

    it "returns a valid index key for the instance" do
      instance = subject.new
      instance.garner_index_key.should == "TestModel/#{instance.id}"
    end

    it "returns a valid set of all index keys, which includes the class" do
      subject.all_garner_index_keys.should include "TestModel"
      instance = subject.new
      instance.all_garner_index_keys.should include "TestModel/#{instance.id}"
      instance.all_garner_index_keys.should include "TestModel"
    end
  end

  context "with multiple identity fields" do
    before(:each) do
      Garner.configure do |config|
        config.mongoid_identity_fields = [:_id, :_slugs, :handle]
      end
    end

    subject do
      class TestModel
        include Mongoid::Document

        def _slugs
          [ "#{id}-slug", "#{id}-slug-2" ]
        end

        def handle
          "handle"
        end
      end
      TestModel
    end

    it "returns a valid index key for the instance" do
      instance = subject.new
      instance.garner_index_key.should == "TestModel/#{instance.id}"
    end

    it "returns a valid set of all index keys, which includes the class" do
      instance = subject.new
      instance.all_garner_index_keys.should include "TestModel/#{instance.id}"
      instance.all_garner_index_keys.should include "TestModel/#{instance.id}-slug"
      instance.all_garner_index_keys.should include "TestModel/#{instance.id}-slug-2"
      instance.all_garner_index_keys.should include "TestModel/handle"
      instance.all_garner_index_keys.should include "TestModel"
    end
  end

  context "with inheritance" do
    subject do
      class TestModel
        include Mongoid::Document
      end

      class TestSubmodel < TestModel
      end
      TestSubmodel
    end

    it "returns a valid index key for the class" do
      subject.garner_index_key.should == "TestModel"
    end

    it "returns a valid index key for the instance" do
      instance = subject.new
      instance.garner_index_key.should == "TestModel/#{instance.id}"
    end

    it "returns a valid set of all index keys, which includes the class" do
      instance = subject.new
      instance.all_garner_index_keys.should include "TestModel/#{instance.id}"
      instance.all_garner_index_keys.should include "TestModel"
    end
  end

end
