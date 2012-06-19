require 'spec_helper'

describe Garner::Keys::Strategies::Noop do
  [ nil, {}, { :x => :y } ].each do |example|
    it "#{example}" do
      Garner::Keys::Strategies::Noop.apply(example).should eq example
    end
  end
end
