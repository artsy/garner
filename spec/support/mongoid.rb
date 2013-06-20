require "garner/mixins/mongoid"
require "mongoid_slug"

# Use garner_test database for integration tests
Mongoid.load_configuration({
  :sessions => {
    :default => {
      :uri => ENV["GARNER_MONGO_URL"] || "mongodb://localhost/garner_test",
      :safe => true
    }
  },
  :options => {
    :raise_not_found_error => false,
    :identity_map_enabled => false
  }
})

if ENV["GARNER_MONGOID_LOG"]
  Mongoid.logger = Logger.new(ENV["GARNER_MONGOID_LOG"])
  Moped.logger = Mongoid.logger
end

# Include mixin
module Mongoid
  module Document
    include Garner::Mixins::Mongoid::Document
  end
end

# Stub classes
class Monger
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  embeds_one :fish
  has_many :cheeses

  field :name, :type => String
  slug :name, :history => true

  field :subdocument, :type => String
end

class Food
  include Mongoid::Document
  include Mongoid::Timestamps

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
    Mongoid.models.each(&:create_indexes)
  end
end
