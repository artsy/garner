$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "coveralls"
Coveralls.wear!("test_frameworks") if ENV["CI"]

require "pry"
require "rspec"
require "rack/test"

require "garner"

# Load shared examples
["shared/*.rb", "support/*.rb"].each do |path|
  Dir["#{File.dirname(__FILE__)}/#{path}"].each do |file|
    require file
  end
end
