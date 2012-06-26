require 'spec_helper'

describe Garner::Strategies::Keys::Key do
  subject do
    Garner::Strategies::Keys::Key
  end
  it "adds a key" do
    subject.apply({}).should eq({})
    subject.apply({}, { :key => "value" }).should eq({ :key => "value" })
  end
end
