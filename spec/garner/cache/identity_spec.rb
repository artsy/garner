require "spec_helper"

describe Garner::Cache::Identity do
  before(:each) do
    Garner.config.reset!
  end

  subject { Garner::Cache::Identity }

  it "includes Garner.config.global_cache_options" do
    Garner.configure { |config| config.global_cache_options = { :foo => "bar" } }
    subject.new.options_hash[:foo].should == "bar"
  end

  it "includes Garner.config.expires_in" do
    Garner.configure { |config| config.expires_in = 5.minutes }
    subject.new.options_hash[:expires_in].should == 5.minutes
  end
end
