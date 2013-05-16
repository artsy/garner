# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "garner"
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Doubrovkine", "Frank Macreery"]
  s.date = "2013-05-16"
  s.description = "Garner is a set of Rack middleware and cache helpers that implement various strategies."
  s.email = "dblock@dblock.org"
  s.extra_rdoc_files = [
    "LICENSE.md",
    "README.md"
  ]
  s.files = [
    "lib/garner.rb",
    "lib/garner/cache/object_identity.rb",
    "lib/garner/config.rb",
    "lib/garner/middleware/base.rb",
    "lib/garner/middleware/cache/bust.rb",
    "lib/garner/mixins/grape_cache.rb",
    "lib/garner/mixins/mongoid_document.rb",
    "lib/garner/strategies/cache/expiration_strategy.rb",
    "lib/garner/strategies/etags/grape_strategy.rb",
    "lib/garner/strategies/etags/marshal_strategy.rb",
    "lib/garner/strategies/keys/caller_strategy.rb",
    "lib/garner/strategies/keys/jsonp_strategy.rb",
    "lib/garner/strategies/keys/key_strategy.rb",
    "lib/garner/strategies/keys/request_get_strategy.rb",
    "lib/garner/strategies/keys/request_path_strategy.rb",
    "lib/garner/strategies/keys/request_post_strategy.rb",
    "lib/garner/strategies/keys/version_strategy.rb",
    "lib/garner/version.rb"
  ]
  s.homepage = "http://github.com/artsy/garner"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Garner is a set of Rack middleware and cache helpers that implement various strategies."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<multi_json>, [">= 1.3.0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 1.3.0"])
      s.add_development_dependency(%q<grape>, [">= 0.2.0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 2.10.0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<mongoid>, [">= 3.0.0"])
      s.add_development_dependency(%q<dalli>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<redcarpet>, [">= 0"])
      s.add_development_dependency(%q<github-markup>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<multi_json>, [">= 1.3.0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 1.3.0"])
      s.add_dependency(%q<grape>, [">= 0.2.0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 2.10.0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<mongoid>, [">= 3.0.0"])
      s.add_dependency(%q<dalli>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<redcarpet>, [">= 0"])
      s.add_dependency(%q<github-markup>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<multi_json>, [">= 1.3.0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 1.3.0"])
    s.add_dependency(%q<grape>, [">= 0.2.0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 2.10.0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<mongoid>, [">= 3.0.0"])
    s.add_dependency(%q<dalli>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<redcarpet>, [">= 0"])
    s.add_dependency(%q<github-markup>, [">= 0"])
  end
end

