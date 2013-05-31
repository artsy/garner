describe Garner::Strategies::BindingKey::CacheKey do

  before(:each) do
    class TestModel
      include Mongoid::Document
    end
  end

  subject { Garner::Strategies::BindingKey::CacheKey }

  let(:binding) { TestModel.new }
  it_should_behave_like "Garner::Strategies::BindingKey strategy"
end
