require 'spec_helper'

describe Garner::Objects::ETag do
  DIGEST_LENGTH = 16 * 2 + 2 # MD5 with quotes
  it "generates an ETag for nil identical to blank" do
    Garner::Objects::ETag.from("").should eq Garner::Objects::ETag.from(nil)
    Garner::Objects::ETag.from(nil).should eq %("#{Digest::MD5.hexdigest("")}")
    Garner::Objects::ETag.from("").should_not eq Garner::Objects::ETag.from(0)
  end
  it "generates an ETag for a string" do
    Garner::Objects::ETag.from("forty two").length.should eq DIGEST_LENGTH
    Garner::Objects::ETag.from("forty two").should_not == Garner::Objects::ETag.from("forty three")
  end
  it "generates an ETag for a number" do
    Garner::Objects::ETag.from(42).length.should eq DIGEST_LENGTH
    Garner::Objects::ETag.from(42).should_not == Garner::Objects::ETag.from(43)
  end
  it "generates an ETag for a hash" do
    Garner::Objects::ETag.from({ :x => :y }).length.should eq DIGEST_LENGTH
    Garner::Objects::ETag.from({ :x => :y }).should_not == Garner::Objects::ETag.from({ :y => :x })
  end
end
