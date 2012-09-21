require 'spec_helper'

describe Garner::Strategies::Keys::Caller do
  subject do
    Garner::Strategies::Keys::Caller
  end
  it "adds a caller line" do
    subject.apply({})[:caller].should match "#{__FILE__}:#{__LINE__}"
  end
  it "bypasses the caller line if :caller is set to nil in the context" do
    subject.apply({}, { :caller => nil })[:caller].should be_nil
  end
end
