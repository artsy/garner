require 'rubygems'
require 'bundler'

require File.expand_path('../lib/garner/version', __FILE__)

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'yard'
YARD::Rake::YardocTask.new(:doc)

task :benchmark do
  require 'performance/strategy_benchmark'
  StrategyBenchmark.new(
    n: ENV['N'].try(&:to_i),
    d: ENV['D'].try(&:to_i),
    r: ENV['R'].try(&:to_i)
  ).run!
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

task default: [:rubocop, :spec]
