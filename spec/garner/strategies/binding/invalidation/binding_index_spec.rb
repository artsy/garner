require 'spec_helper'

describe Garner::Strategies::Binding::Invalidation::BindingIndex do

  before(:each) do
    @mock = double('model')
    allow(@mock).to receive(:touch)
  end

  subject { Garner::Strategies::Binding::Invalidation::BindingIndex }

  it_behaves_like 'Garner::Strategies::Binding::Invalidation strategy'

end
