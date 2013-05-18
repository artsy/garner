require 'spec_helper'

describe Garner::Strategies::Keys::Caller do
  subject do
    Garner::Strategies::Keys::Caller
  end
  it "adds a caller line" do
    subject.apply({})[:caller].should match "#{__FILE__}:#{__LINE__}"
  end
  it "ignores nil caller" do
    subject.stub(:caller).and_return(nil)
    subject.apply({})[:caller].should be_nil
  end
  it "ignores nil caller location" do
    subject.stub(:caller).and_return([ nil ])
    subject.apply({})[:caller].should be_nil
  end
  it "ignores blank caller location" do
    subject.stub(:caller).and_return([ "" ])
    subject.apply({})[:caller].should be_nil
  end
  it "doesn't require ActiveSupport" do
    String.any_instance.stub(:blank?) { raise NoMethodError.new }
    subject.apply({})[:caller].should match "#{__FILE__}:#{__LINE__}"
  end
end
