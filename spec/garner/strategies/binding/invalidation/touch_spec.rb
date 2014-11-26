require 'spec_helper'

describe Garner::Strategies::Binding::Invalidation::Touch do

  before(:each) do
    @mock = double('model')
    allow(@mock).to receive(:touch)
  end

  subject { Garner::Strategies::Binding::Invalidation::Touch }

  it_behaves_like 'Garner::Strategies::Binding::Invalidation strategy'

  it 'calls :touch on the object' do
    expect(@mock).to receive(:touch)
    subject.apply(@mock)
  end

  it 'does not raise error if :touch is undefined' do
    allow(@mock).to receive(:touch)
    expect { subject.apply(@mock) }.to_not raise_error
  end
end
