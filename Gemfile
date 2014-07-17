source "http://rubygems.org"

gem "rack"
gem "json"
gem "multi_json",   ">= 1.3.0"
gem "activesupport"

group :development, :test do
  gem "bundler"
  gem "grape",      "~> 0.8.0"
  gem "sinatra"
  gem "rack-test"
  gem "rspec",      "~> 2.10.0"
  gem "jeweler"
  case version = ENV['MONGOID_VERSION'] || '~> 4.0'
  when /4/
    gem 'mongoid', '~> 4.0'
  when /3/
    gem 'mongoid', '~> 3.1'
  else
    gem 'mongoid', version
  end
  gem "mongoid_slug"
  gem "dalli"
  gem "activerecord"
  gem "sqlite3"
  gem "coveralls"
  gem "method_profiler"
end

group :development do
  gem "pry"
  gem "yard"
  gem "redcarpet"
  gem "github-markup"
end
