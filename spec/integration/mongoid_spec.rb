require "spec_helper"
require "garner/mixins/mongoid"

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
              @object = Monger.create!({ :name => "M1" })
            end
          end

          context "to a real Mongoid object" do
            let(:cached_object_namer) do
              lambda do
                found = Monger.find(@object.id)
                @app.garner.bind(found) { found.name }
              end
            end

            it "invalidates on update" do
              cached_object_namer.call.should == "M1"
              @object.update_attributes!({ :name => "M2" })
              cached_object_namer.call.should == "M2"
            end

            it "invalidates on destroy" do
              cached_object_namer.call.should == "M1"
              @object.destroy
              cached_object_namer.should raise_error
            end

            it "invalidates by explicit call to invalidate_garner_caches" do
              cached_object_namer.call.should == "M1"
              @object.set(:name, "M2")
              @object.invalidate_garner_caches
              cached_object_namer.call.should == "M2"
            end

            it "does not invalidate results for other like-classed objects" do
              cached_object_namer.call.should == "M1"
              @object.set({ :name => "M2" })

              new_monger = Monger.create!({ :name => "M3" })
              new_monger.update_attributes!({ :name => "M4" })
              new_monger.destroy

              cached_object_namer.call.should == "M1"
            end

            context "with inheritance" do
              before(:each) do
                Timecop.freeze(1.second.ago) do
                  @monger = Monger.create!({ :name => "M1" })
                  @object = Cheese.create!({ :name => "Swiss", :monger => @monger })
                end
              end

              let(:cached_object_namer) do
                lambda do
                  found = Food.find(@object.id)
                  @app.garner.bind(found) { found.name }
                end
              end

              it "binds to the correct object" do
                cached_object_namer.call.should == "Swiss"
                @object.update_attributes!({ :name => "Havarti" })
                cached_object_namer.call.should == "Havarti"
              end
            end

            context "with an embedded document" do
              before(:each) do
                Timecop.freeze(1.second.ago) do
                  @fish = Monger.create!({ :name => "M1" }).create_fish({ :name => "Trout" })
                end
              end

              let(:cached_object_namer) do
                lambda do
                  found = Monger.where({ "fish._id" => @fish.id }).first.fish
                  @app.garner.bind(found) { found.name }
                end
              end

              it "binds to the correct object" do
                cached_object_namer.call.should == "Trout"
                @fish.update_attributes!({ :name => "Sockeye" })
                cached_object_namer.call.should == "Sockeye"
              end
            end

            context "with multiple identities" do
              before(:each) do
                Garner.configure do |config|
                  config.mongoid_identity_fields = [:_id, :_slugs]
                end
              end

              let(:cached_object_namer_by_slug) do
                lambda do |slug|
                  found = Monger.find(slug)
                  binding.pry if found.nil?
                  @app.garner.bind(found) { found.name }
                end
              end

              it "invalidates all identities" do
                cached_object_namer.call.should == "M1"
                cached_object_namer_by_slug.call("m1").should == "M1"
                @object.update_attributes!({ :name => "M2" })
                cached_object_namer.call.should == "M2"
                cached_object_namer_by_slug.call("m1").should == "M2"
              end
            end
          end
        end

        context "binding at the class level" do
          let(:cached_object_name_concatenator) do
            lambda do
              @app.garner.bind(Monger) { Monger.all.map(&:name).join(", ") }
            end
          end
          it "invalidates on create" do
            cached_object_name_concatenator.call.should == ""
            Monger.create({ :name => "M1" })
            cached_object_name_concatenator.call.should == "M1"
          end

          it "invalidates on update" do
            monger = Monger.create({ :name => "M1" })
            cached_object_name_concatenator.call.should == "M1"
            monger.update_attributes({ :name => "M2" })
            cached_object_name_concatenator.call.should == "M2"
          end

          it "invalidates on destroy" do
            monger = Monger.create({ :name => "M1" })
            cached_object_name_concatenator.call.should == "M1"
            monger.destroy
            cached_object_name_concatenator.call.should == ""
          end

          it "invalidates by explicit call to invalidate_garner_caches" do
            monger = Monger.create({ :name => "M1" })
            cached_object_name_concatenator.call.should == "M1"
            monger.set(:name, "M2")
            Monger.invalidate_garner_caches
            cached_object_name_concatenator.call.should == "M2"
          end
        end
      end
    end
  end
end
