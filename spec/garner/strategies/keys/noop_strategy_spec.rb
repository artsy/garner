require 'spec_helper'

describe Garner::Strategies::Keys::Noop do
  subject do
    Garner::Strategies::Keys::Noop
  end
  [ nil, {}, { :x => :y } ].each do |example|
    it "#{example}" do
      subject.apply(example).should eq example
    end
  end
end
