require "spec_helper"
require "garner/mixins/mongoid_document"

describe "Mongoid integration" do
  before(:each) do
    @app = Class.new.tap do |app|
      app.send(:extend, Garner::Cache::Context)
    end
  end

  [ Garner::Strategies::Binding::Key::CacheKey ].each do |key_strategy|
    context "using #{key_strategy}" do
      describe "cache key generation" do
        subject { key_strategy }

        it_behaves_like "Garner::Strategies::Binding::Key strategy" do
          let(:known_bindings) { [ Monger.create ] }
          let(:unknown_bindings) { [] }
        end
      end
    end
  end

  {
    Garner::Strategies::Binding::Key::CacheKey =>
      Garner::Strategies::Binding::Invalidation::Touch
  }.each do |key_strategy, invalidation_strategy|
    context "using #{key_strategy} with #{invalidation_strategy}" do
      describe "end-to-end caching and invalidation" do
        context "binding at the instance level" do
          before(:each) do
            Garner.configure do |config|
              config.mongoid_binding_key_strategy = key_strategy
              config.mongoid_binding_invalidation_strategy = invalidation_strategy
            end

            Timecop.freeze(1.second.ago) do
              @monger = Monger.create!({ :name => "M1" })
            end
          end

          context "to a real Mongoid object" do
            let(:cached_monger_namer) do
              lambda {
                found = Monger.find(@monger.id)
                @app.garner.bind(found) { found.name }
              }
            end

            it "invalidates on update" do
              cached_monger_namer.call.should == "M1"
              @monger.update_attributes!({ :name => "M2" })
              cached_monger_namer.call.should == "M2"
            end

            it "invalidates on destroy" do
              cached_monger_namer.call.should == "M1"
              @monger.destroy
              cached_monger_namer.should raise_error
            end

            it "invalidates by explicit call to invalidate_garner_caches" do
              cached_monger_namer.call.should == "M1"
              @monger.set(:name, "M2")
              @monger.invalidate_garner_caches
              cached_monger_namer.call.should == "M2"
            end

            it "does not invalidate results for other like-classed objects" do
              cached_monger_namer.call.should == "M1"
              @monger.set({ :name => "M2" })

              new_monger = Monger.create!({ :name => "M3" })
              new_monger.update_attributes!({ :name => "M4" })
              new_monger.destroy

              cached_monger_namer.call.should == "M1"
            end

            context "with inheritance" do
              it "binds to the correct object" do
              end
            end

            context "with an embedded document" do
              it "binds to the correct object"
            end

            context "with multiple identity fields" do
              it "invalidates all identities"
            end
          end
        end

        context "binding at the class level" do
          it "invalidates on create"

          it "invalidates on update"

          it "invalidates on destroy"
        end
      end
    end
  end
end
