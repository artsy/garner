describe Garner::Strategies::BindingInvalidation::Touch do

  before(:each) do
    @mock = double "model"
    @mock.stub(:touch) {  }
  end

  it_behaves_like "Garner::Strategies::BindingInvalidation strategy"

  it "calls :touch on the object" do
    @mock.should_receive(:touch)
    subject.apply(@mock)
  end

  it "does not raise error if :touch is undefined" do
    @mock.unstub(:touch)
    expect { subject.apply(@mock) }.to_not raise_error
  end
end
