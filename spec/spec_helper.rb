$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rspec"
require "grape"
require "sinatra"
require "rack/test"
require "mongoid"
require "garner"

# Load shared examples
Dir["#{File.dirname(__FILE__)}/shared/*.rb"].each do |file|
  require file
end
