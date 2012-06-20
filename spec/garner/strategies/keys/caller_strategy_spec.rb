require 'spec_helper'

describe Garner::Strategies::Keys::Caller do
  subject do
    Garner::Strategies::Keys::Caller
  end
  it "adds a caller line" do
    subject.apply({})[:caller].should match "#{__FILE__}:#{__LINE__}"
  end
end
