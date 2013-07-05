require "spec_helper"
require "garner/mixins/mongoid"

describe "Mongoid integration" do
  before(:each) do
    @app = Class.new.tap do |app|
      app.send(:extend, Garner::Cache::Context)
    end
  end

  {
    # Garner::Strategies::Binding::Key::SafeCacheKey =>
    #   Garner::Strategies::Binding::Invalidation::Touch,
    Garner::Strategies::Binding::Key::BindingIndex =>
      Garner::Strategies::Binding::Invalidation::BindingIndex
  }.each do |key_strategy, invalidation_strategy|
    context "using #{key_strategy} with #{invalidation_strategy}" do
      before(:each) do
        Garner.configure do |config|
          config.binding_key_strategy = key_strategy
          config.binding_invalidation_strategy = invalidation_strategy
        end
      end

      describe "end-to-end caching and invalidation" do
        context "binding at the instance level" do
          before(:each) do
            @object = Monger.create!({ :name => "M1" })
          end

          describe "garnered_find" do
            before(:each) do
              Garner.configure do |config|
                config.mongoid_identity_fields = [:_id, :_slugs]
              end
            end

            it "caches one copy across all callers" do
              Monger.stub(:find) { @object }
              Monger.should_receive(:find).once
              2.times { Monger.garnered_find("m1") }
            end

            it "returns the instance requested" do
              Monger.garnered_find("m1").should == @object
            end

            it "is invalidated on changing identity field" do
              Monger.garnered_find("m1").name.should == "M1"
              @object.update_attributes!({ :name => "M2" })
              Monger.garnered_find("m1").name.should == "M2"
            end

            it "is invalidated on destruction" do
              Monger.garnered_find("m1").name.should == "M1"
              @object.destroy
              Monger.garnered_find("m1").should be_nil
            end

            context "with case-insensitive find" do
              before(:each) do
                _find = Monger.method(:find)
                Monger.stub(:find) do |param|
                  _find.call(param.to_s.downcase)
                end
              end

              it "does not cache a nil identity" do
                Monger.garnered_find("M1").should == @object
                Monger.garnered_find("foobar").should be_nil
              end
            end
          end

          [:find, :identify].each do |selection_method|
            context "binding via #{selection_method}" do
              let(:cached_object_namer) do
                lambda do
                  binding = Monger.send(selection_method, @object.id)
                  object = Monger.find(@object.id)
                  @app.garner.bind(binding) { object.name }
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

              context "with racing destruction" do
                before(:each) do
                  # Define two Mongoid objects for the race
                  @monger1, @monger2 = 2.times.map { Monger.find(@object.id) }
                end

                it "invalidates caches properly (Type I)" do
                  cached_object_namer.call
                  @monger1.remove
                  @monger2.set(:name, "M2")
                  @monger1.destroy
                  @monger2.save
                  cached_object_namer.should raise_error
                end

                it "invalidates caches properly (Type II)" do
                  cached_object_namer.call
                  @monger2.set(:name, "M2")
                  @monger1.remove
                  @monger2.save
                  @monger1.destroy
                  cached_object_namer.should raise_error
                end
              end

              context "with inheritance" do
                before(:each) do
                  @monger = Monger.create!({ :name => "M1" })
                  @object = Cheese.create!({ :name => "Swiss", :monger => @monger })
                end

                let(:cached_object_namer) do
                  lambda do
                    binding = Food.send(selection_method, @object.id)
                    object = Food.find(@object.id)
                    @app.garner.bind(binding) { object.name }
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
                  @monger = Monger.create!({ :name => "M1" })
                  @fish = @monger.create_fish({ :name => "Trout" })
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

                context "with :invalidate_mongoid_root = true" do
                  before(:each) do
                    Garner.configure do |config|
                      config.invalidate_mongoid_root = true
                    end
                  end

                  let(:root_cached_object_namer) do
                    lambda do
                      binding = Monger.send(selection_method, @monger.id)
                      @app.garner.bind(binding) { @monger.fish.name }
                    end
                  end

                  it "invalidates the root document" do
                    root_cached_object_namer.call.should == "Trout"
                    @fish.update_attributes!({ :name => "Sockeye" })
                    root_cached_object_namer.call.should == "Sockeye"
                  end
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
                    binding = Monger.send(selection_method, slug)
                    object = Monger.find(slug)
                    @app.garner.bind(binding) { object.name }
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
        end

        context "binding at the class level" do
          ["top-level class", "subclass"].each do |level|
            context "to a #{level}" do
              let (:klass) { level == "subclass" ? Cheese : Food }

              let(:cached_object_name_concatenator) do
                lambda do
                  @app.garner.bind(klass) do
                    klass.all.order_by(:_id => :asc).map(&:name).join(", ")
                  end
                end
              end

              it "invalidates on create" do
                m1 = Cheese.create({ :name => "M1" })
                cached_object_name_concatenator.call.should == "M1"
                m1 = Cheese.create({ :name => "M3" })
                cached_object_name_concatenator.call.should == "M1, M3"
              end

              it "invalidates on update" do
                m1 = Cheese.create({ :name => "M1" })
                m3 = Cheese.create({ :name => "M3" })
                cached_object_name_concatenator.call.should == "M1, M3"
                m1.update_attributes({ :name => "M2" })
                cached_object_name_concatenator.call.should == "M2, M3"
              end

              it "invalidates on destroy" do
                m1 = Cheese.create({ :name => "M1" })
                m3 = Cheese.create({ :name => "M3" })
                cached_object_name_concatenator.call.should == "M1, M3"
                m1.destroy
                cached_object_name_concatenator.call.should == "M3"
              end

              it "invalidates by explicit call to invalidate_garner_caches" do
                m1 = Cheese.create({ :name => "M1" })
                m3 = Cheese.create({ :name => "M3" })
                cached_object_name_concatenator.call.should == "M1, M3"
                m1.set(:name, "M2")
                klass.invalidate_garner_caches
                cached_object_name_concatenator.call.should == "M2, M3"
              end
            end
          end
        end
      end
    end
  end
end
