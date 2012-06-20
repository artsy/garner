require 'spec_helper'

describe Garner::Strategies::Keys::Version do
  subject do
    Garner::Strategies::Keys::Version
  end
  it "adds version" do
    subject.apply({}).should eq({})
    subject.apply({ :version => "v1" }, @options).should eq({ :version => "v1" })
  end
end
