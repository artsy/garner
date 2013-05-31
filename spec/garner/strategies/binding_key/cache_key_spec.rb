describe Garner::Strategies::BindingKey::CacheKey do

  before(:each) do
    class TestModel
      include Mongoid::Document
    end
  end

  it_behaves_like "Garner::Strategies::BindingKey strategy" do
    let(:known_bindings) { [ TestModel.new ] }
    let(:unknown_bindings) { [ TestModel ] }
  end

end
