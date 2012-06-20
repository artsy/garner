require 'spec_helper'

describe Garner::Strategies::Cache::Expiration do
  subject do
    Garner::Strategies::Cache::Expiration
  end
  it "adds no expiration" do
    subject.apply({}).keys.should_not include(:expires_in)
  end
  context "with configured expiration" do
    before :each do
      Garner.config.expires_in = 12 * 60 * 60
    end
    it "adds expiration" do
      subject.apply({})[:expires_in].should == 12 * 60 * 60
    end
    after :each do
      Garner.config.reset!
    end
  end
end
