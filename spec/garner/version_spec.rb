require 'spec_helper'

describe Garner::VERSION do
  subject do
    Garner::VERSION
  end
  it 'is valid' do
    expect(subject).not_to be_nil
    expect(!!Gem::Version.correct?(subject)).to be_truthy
  end
end
