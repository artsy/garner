require 'spec_helper'

describe Garner::Keys::Strategies::Base do
  [ nil, {}, { :x => :y } ].each do |example|
    it "#{example}" do
      Garner::Keys::Strategies::Base.apply(example).should eq example
    end
  end
end
