require 'rubygems'
require 'bundler'

require File.expand_path('../lib/garner/version', __FILE__)

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "garner"
  gem.homepage = "http://github.com/dblock/garner"
  gem.license = "MIT"
  gem.summary = "Garner is a set of Rack middleware and cache helpers that implement various strategies."
  gem.description = "Garner is a set of Rack middleware and cache helpers that implement various strategies."
  gem.email = "dblock@dblock.org"
  gem.version = Garner::VERSION
  gem.authors = [ "Daniel Doubrovkine", "Frank Macreery" ]
  gem.files = Dir.glob('lib/**/*')
end

Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'yard'
YARD_OPTS = ['-m', 'github-markup', '-M', 'redcarpet']
DOC_FILES = ['lib/**/*.rb', '*.md']

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = DOC_FILES
  t.options = YARD_OPTS
end

