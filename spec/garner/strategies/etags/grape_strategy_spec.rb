require 'spec_helper'

describe Garner::Strategies::ETags::Grape do
  DIGEST_LENGTH = 16 * 2 + 2 # MD5 with quotes
  subject do
    Garner::Strategies::ETags::Grape
  end
  it "generates an ETag for nil identical to blank" do
    subject.apply("").should eq subject.apply(nil)
    subject.apply(nil).should eq %("#{Digest::MD5.hexdigest("")}")
    subject.apply("").should_not eq subject.apply(0)
  end
  it "generates an ETag for a string" do
    subject.apply("forty two").length.should eq DIGEST_LENGTH
    subject.apply("forty two").should_not == subject.apply("forty three")
  end
  it "generates an ETag for a number" do
    subject.apply(42).length.should eq DIGEST_LENGTH
    subject.apply(42).should_not == subject.apply(43)
  end
  it "generates an ETag for a hash" do
    subject.apply({ :x => :y }).length.should eq DIGEST_LENGTH
    subject.apply({ :x => :y }).should_not == subject.apply({ :y => :x })
  end
end
