$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'garner'
require 'grape'
require 'rack/test'
require 'mongoid'

[ "support/*.rb" ].each do |path|
  Dir["#{File.dirname(__FILE__)}/#{path}"].each do |file|
    require file
  end
end

