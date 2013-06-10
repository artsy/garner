require "garner/mixins/mongoid"
require "mongoid_slug"

# Use garner_test database for integration tests
yaml = File.join(File.dirname(__FILE__), "mongoid.yml")
Mongoid.load!(yaml, :test)

# Stub classes
class Monger
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  include Garner::Mixins::Mongoid::Document
  embeds_one :fish
  has_many :cheeses

  field :name, :type => String
  slug :name, :history => true
end

class Food
  include Mongoid::Document
  include Mongoid::Timestamps
  include Garner::Mixins::Mongoid::Document

  field :name, :type => String
end

class Fish < Food
  embedded_in :monger
end

class Cheese < Food
  include Mongoid::Slug
  belongs_to :monger

  slug :name, :history => true
end

# Purge MongoDB database before each test example
RSpec.configure do |config|
  config.before(:each) do
    Mongoid.purge!
  end
end
