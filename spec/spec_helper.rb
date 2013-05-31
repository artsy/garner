$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rspec"
require "grape"
require "sinatra"
require "rack/test"
require "mongoid"
require "garner"
require "active_record"

# Load shared examples
[ "shared/*.rb", "support/*.rb" ].each do |path|
  Dir["#{File.dirname(__FILE__)}/#{path}"].each do |file|
    require file
  end
end
