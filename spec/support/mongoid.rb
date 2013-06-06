require "garner/mixins/mongoid_document"

# Use garner_test database for integration tests
yaml = File.join(File.dirname(__FILE__), "mongoid.yml")
Mongoid.load!(yaml, :test)

# Stub classes
class Monger
  include Mongoid::Document
  include Mongoid::Timestamps
  include Garner::Mixins::Mongoid::Document
  embeds_many :fish
  has_many :cheeses

  field :name, :type => String
end

class Food
  include Mongoid::Document
  include Mongoid::Timestamps
  include Garner::Mixins::Mongoid::Document
end

class Fish < Food
  embedded_in :monger
end

class Cheese < Food
  belongs_to :monger
end

# Purge MongoDB database before each test example
RSpec.configure do |config|
  config.before(:each) do
    Mongoid.purge!
  end
end
