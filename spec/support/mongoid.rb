require 'garner/mixins/mongoid'
require 'mongoid_slug'

Mongoid.configure do |config|
  config.connect_to 'garner_test'
  config.raise_not_found_error = false
end

Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::INFO if Mongoid::Compatibility::Version.mongoid5?

# Include mixin
module Mongoid
  module Document
    include Garner::Mixins::Mongoid::Document
  end

  def self.mongoid3?
    ::Mongoid.const_defined? :Observer # deprecated in Mongoid 4.x
  end
end

# Stub classes
class Monger
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  embeds_one :fish
  has_many :cheeses

  field :name, type: String
  slug :name, history: true

  field :subdocument, type: String
end

class Food
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
end

class Fish < Food
  embedded_in :monger
end

class Cheese < Food
  include Mongoid::Slug
  belongs_to :monger

  slug :name, history: true
end

# Purge MongoDB database before each test example
RSpec.configure do |config|
  config.before(:each) do
    Mongoid.purge!
    Mongoid.models.each(&:create_indexes)
  end
end
