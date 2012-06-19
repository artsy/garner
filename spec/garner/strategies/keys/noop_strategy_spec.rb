require 'spec_helper'

describe Garner::Strategies::Keys::Noop do
  [ nil, {}, { :x => :y } ].each do |example|
    it "#{example}" do
      Garner::Strategies::Keys::Noop.apply(example).should eq example
    end
  end
end
