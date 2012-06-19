require 'spec_helper'

describe Garner do
  it "has a version" do
    Garner::VERSION.should_not be_nil
    Garner::VERSION.to_f.should > 0
  end
end


