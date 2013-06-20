require "rubygems"
require "bundler"

require File.expand_path("../lib/garner/version", __FILE__)

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "rake"

require "jeweler"
Jeweler::Tasks.new do |gem|
  gem.name = "garner"
  gem.homepage = "http://github.com/artsy/garner"
  gem.license = "MIT"
  gem.summary = "Garner is a cache layer for Ruby and Rack applications, supporting model and instance binding and hierarchical invalidation."
  gem.description = "Garner is a cache layer for Ruby and Rack applications, supporting model and instance binding and hierarchical invalidation."
  gem.email = "dblock@dblock.org"
  gem.version = Garner::VERSION
  gem.authors = ["Daniel Doubrovkine", "Frank Macreery"]
  gem.files = Dir.glob("lib/**/*")
end

Jeweler::RubygemsDotOrgTasks.new

require "rspec/core"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList["spec/**/*_spec.rb"]
end

task :default => :spec

require "yard"
YARD::Rake::YardocTask.new(:doc)

task :benchmark do
  require "performance/strategy_benchmark"
  StrategyBenchmark.new({
    :n => ENV["N"].try(&:to_i),
    :d => ENV["D"].try(&:to_i),
    :r => ENV["R"].try(&:to_i)
  }).run!
end
