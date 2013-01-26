require 'spec_helper'

describe Garner do
  it "does not depend on unnecessary active_support methods" do
    "".blank?.should raise_error
  end
end
