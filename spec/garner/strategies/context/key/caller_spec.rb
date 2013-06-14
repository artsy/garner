require "spec_helper"

describe Garner::Strategies::Context::Key::Caller do
  before(:each) do
    @cache_identity = Garner::Cache::Identity.new
    @mock_context = double("object")
  end

  subject { Garner::Strategies::Context::Key::Caller }

  it_behaves_like "Garner::Strategies::Context::Key strategy"

  it "adds a caller line" do
    subject.apply(@cache_identity, self)
    @cache_identity.key_hash[:caller].should match "#{__FILE__}:#{__LINE__-1}"
  end

  it "ignores nil caller" do
    @mock_context.stub(:caller) { nil }
    subject.apply(@cache_identity, @mock_context)
    @cache_identity.key_hash[:caller].should be_nil
  end

  it "ignores nil caller location" do
    @mock_context.stub(:caller) { [nil] }
    subject.apply(@cache_identity, @mock_context)
    @cache_identity.key_hash[:caller].should be_nil
  end

  it "ignores blank caller location" do
    @mock_context.stub(:caller) { [""] }
    subject.apply(@cache_identity, @mock_context)
    @cache_identity.key_hash[:caller].should be_nil
  end

  it "doesn't require ActiveSupport" do
    String.any_instance.stub(:blank?) { raise NoMethodError.new }
    subject.apply(@cache_identity, self)
    @cache_identity.key_hash[:caller].should match "#{__FILE__}:#{__LINE__-1}"
  end
end
