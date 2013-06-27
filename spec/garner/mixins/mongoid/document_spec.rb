require "spec_helper"
require "garner/mixins/mongoid"

describe Garner::Mixins::Mongoid::Document do
  context "at the instance level" do
    before(:each) do
      Garner.configure do |config|
        config.mongoid_identity_fields = [:_id, :_slugs]
      end

      @monger = Monger.create({ :name => "M1" })
      @cheese = Cheese.create({ :name => "M1" })
    end

    describe "proxied_classes" do
      it "returns all Mongoid superclasses" do
        @monger.proxied_classes.should == [Monger]
        @cheese.proxied_classes.should == [Cheese, Food]
      end
    end
  end

  context "at the class level" do
    subject { Monger }

    describe "_latest_by_updated_at" do
      it "returns a Mongoid::Document instance" do
        subject.create
        subject.send(:_latest_by_updated_at).should be_a(subject)
      end

      it "returns the _latest_by_updated_at document by :updated_at" do
        mongers = 3.times.map { |i| subject.create({ :name => "M#{i}" }) }
        mongers[1].touch

        subject.send(:_latest_by_updated_at)._id.should == mongers[1]._id
        subject.send(:_latest_by_updated_at).updated_at.should == mongers[1].reload.updated_at
      end

      it "returns nil if there are no documents" do
        subject.send(:_latest_by_updated_at).should be_nil
      end

      it "returns nil if updated_at does not exist" do
        monger = subject.create
        subject.stub(:fields) { {} }
        subject.send(:_latest_by_updated_at).should be_nil
      end
    end

    describe "proxy_binding" do
      it "returns the _latest_by_updated_at document" do
        monger = subject.create
        subject.proxy_binding.should be_a(Monger)
      end

      it "responds to :touch" do
        monger = subject.create
        subject.any_instance.should_receive(:touch)
        subject.proxy_binding.touch
      end

      describe "cache_key" do
        it "matches what would be returned from the full object" do
          monger = subject.create
          subject.proxy_binding.cache_key.should == monger.reload.cache_key
        end

        context "with Mongoid subclasses" do
          subject { Cheese }

          it "matches what would be returned from the full object" do
            cheese = subject.create
            subject.proxy_binding.cache_key.should == cheese.reload.cache_key
          end
        end
      end
    end
  end
end
