RSpec.configure do |config|
  config.before(:each) do
    Garner.config.reset!
  end
end
