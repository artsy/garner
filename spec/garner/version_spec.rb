require "spec_helper"

describe Garner::VERSION do
  subject do
    Garner::VERSION
  end
  it "is valid" do
    subject.should_not be_nil
    (!!Gem::Version.correct?(subject)).should be_true
  end
end


