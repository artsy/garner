require "spec_helper"

describe "Rack integration" do

  context "with the RequestGet strategy disabled" do
    it "co-caches requests to the same path with different query strings"
  end

  context "with default configuration" do
    it "caches different results for different paths"

    it "caches different results for different query strings"

    it "caches multiple blocks separately within an endpoint"
  end
end
