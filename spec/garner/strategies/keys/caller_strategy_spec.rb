require 'spec_helper'

describe Garner::Strategies::Keys::Caller do
  it "adds a caller line" do
    Garner::Strategies::Keys::Caller.apply({})[:caller].should match "#{__FILE__}:#{__LINE__}"
  end
end
