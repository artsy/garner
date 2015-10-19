$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'garner/version'

Gem::Specification.new do |s|
  s.name = 'garner'
  s.version = Garner::VERSION
  s.authors = ['Daniel Doubrovkine', 'Frank Macreery']
  s.summary = 'Garner is a cache layer for Ruby and Rack applications, supporting model and instance binding and hierarchical invalidation.'
  s.email = ['dblock@dblock.org', 'frank.macreery@gmail.com']
  s.homepage = 'https://github.com/artsy/garner'
  s.license = 'MIT'

  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.test_files = s.files.grep(/^(spec)\//)
  s.extra_rdoc_files = Dir['*.md']
  s.require_paths = ['lib']

  s.post_install_message = File.read('UPGRADING') if File.exist?('UPGRADING')

  s.add_runtime_dependency 'rack'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'multi_json', '>= 1.3.0'
  s.add_runtime_dependency 'activesupport'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'grape', '~> 0.8.0'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'mongoid', '>= 3.0.0'
  s.add_development_dependency 'mongoid-slug'
  s.add_development_dependency 'activerecord'
  if RUBY_PLATFORM =~ /java/
    s.add_development_dependency 'jdbc-sqlite3'
    s.add_development_dependency 'activerecord-jdbcsqlite3-adapter'
  else
    s.add_development_dependency 'sqlite3'
  end
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'dalli'
  s.add_development_dependency 'rubocop', '0.28.0'
end
