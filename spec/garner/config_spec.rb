require "spec_helper"

describe Garner::Config do
  before :each do
    @cache = Garner::Config.cache
  end
  after :each do
    Garner::Config.cache = @cache
  end
  it "configures a cache store" do
    cache = Class.new
    Garner.configure do |config|
      config.cache = cache
    end
    Garner.config.cache.should == cache
  end
end

