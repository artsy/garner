$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "coveralls"
Coveralls.wear!("test_frameworks") if ENV["CI"]

require "garner"

require "rspec"
require "rack/test"

require "grape"
require "sinatra"
require "mongoid"
require "active_record"

# Require pry so that binding.pry will work out of the box for debugging
require "pry"

# Load shared examples
["shared/*.rb", "support/*.rb"].each do |path|
  Dir["#{File.dirname(__FILE__)}/#{path}"].each do |file|
    require file
  end
end
