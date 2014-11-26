require 'spec_helper'

describe Garner::Strategies::Context::Key::Caller do
  before(:each) do
    @cache_identity = Garner::Cache::Identity.new
    @mock_context = double('object')
  end

  subject { Garner::Strategies::Context::Key::Caller }

  it_behaves_like 'Garner::Strategies::Context::Key strategy'

  it 'ignores nil caller' do
    allow(@mock_context).to receive(:caller) { nil }
    subject.apply(@cache_identity, @mock_context)
    expect(@cache_identity.key_hash[:caller]).to be_nil
  end

  it 'ignores nil caller location' do
    allow(@mock_context).to receive(:caller) { [nil] }
    subject.apply(@cache_identity, @mock_context)
    expect(@cache_identity.key_hash[:caller]).to be_nil
  end

  it 'ignores blank caller location' do
    allow(@mock_context).to receive(:caller) { [''] }
    subject.apply(@cache_identity, @mock_context)
    expect(@cache_identity.key_hash[:caller]).to be_nil
  end

  context 'with default Garner.config.caller_root' do
    before(:each) do
      raw_gemfile_parent = File.join(__FILE__, '..', '..', '..', '..', '..', '..')
      @gemfile_root = Pathname.new(raw_gemfile_parent).realpath.to_s
    end

    it 'sets default_root to the nearest ancestor with a Gemfile' do
      expect(subject.default_root).to eq @gemfile_root
    end

    it 'sets Garner.config.caller_root to the nearest ancestor with a Gemfile' do
      expect(Garner.config.caller_root).to eq @gemfile_root
    end

    it 'sets an appropriate value for :caller' do
      truncated = __FILE__.gsub(@gemfile_root + File::SEPARATOR, '')
      subject.apply(@cache_identity, self)
      expect(@cache_identity.key_hash[:caller]).to eq "#{truncated}:#{__LINE__ - 1}"
    end
  end

  context 'with Rails.root defined' do
    before(:each) do
      class Rails
      end
      allow(Rails).to receive(:root) { Pathname.new(File.dirname(__FILE__)) }
    end

    it 'sets default_root to Rails.root' do
      expect(subject.default_root).to eq ::Rails.root.realpath.to_s
    end

    it 'sets Garner.config.caller_root to Rails.root' do
      expect(Garner.config.caller_root).to eq ::Rails.root.realpath.to_s
    end

    it 'sets an appropriate value for :caller' do
      truncated = File.basename(__FILE__)
      subject.apply(@cache_identity, self)
      expect(@cache_identity.key_hash[:caller]).to eq "#{truncated}:#{__LINE__ - 1}"
    end
  end

  context 'with custom Garner.config.caller_root' do
    before(:each) do
      Garner.configure do |config|
        config.caller_root = File.dirname(__FILE__)
      end
    end

    it 'sets an appropriate value for :caller' do
      truncated = File.basename(__FILE__)
      subject.apply(@cache_identity, self)
      expect(@cache_identity.key_hash[:caller]).to eq "#{truncated}:#{__LINE__ - 1}"
    end
  end

  context 'with Garner.config.caller_root unset' do
    before(:each) do
      Garner.configure do |config|
        config.caller_root = nil
      end
    end

    it 'sets an appropriate value for :caller' do
      subject.apply(@cache_identity, self)
      expect(@cache_identity.key_hash[:caller]).to eq "#{__FILE__}:#{__LINE__ - 1}"
    end

    it "doesn't require ActiveSupport" do
      allow_any_instance_of(String).to receive(:blank?) { fail NoMethodError.new }
      subject.apply(@cache_identity, self)
      expect(@cache_identity.key_hash[:caller]).to eq "#{__FILE__}:#{__LINE__ - 1}"
    end
  end
end
