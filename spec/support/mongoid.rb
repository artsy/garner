# Use garner_test database for integration tests
yaml = File.join(File.dirname(__FILE__), "mongoid.yml")
Mongoid.load!(yaml, :test)

RSpec.configure do |config|
  config.before(:each) do
    Mongoid.purge!
  end
end
