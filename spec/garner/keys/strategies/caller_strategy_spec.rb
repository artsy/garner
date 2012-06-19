require 'spec_helper'

describe Garner::Keys::Strategies::Caller do
  it "adds a caller line" do
    Garner::Keys::Strategies::Caller.apply({})[:caller].should match "#{__FILE__}:#{__LINE__}"
  end
end
