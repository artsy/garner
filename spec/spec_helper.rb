$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "coveralls"
Coveralls.wear!("test_frameworks") if ENV["CI"]

require "pry"
require "rspec"
require "rack/test"

require "garner"

# Load support files
require "spec_support"

# Load shared examples
Dir["#{File.dirname(__FILE__)}/shared/*.rb"].each do |file|
  require file
end
