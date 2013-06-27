require "garner"
require "active_support/cache/dalli_store"

if (server = ENV["GARNER_MEMCACHE_SERVER"])
  Garner.configure do |config|
    config.cache = ActiveSupport::Cache::DalliStore.new(server, {
      :compress => !!ENV["GARNER_MEMCACHE_COMPRESS"]
    })
  end
end

# Purge cache before each test example
RSpec.configure do |config|
  config.before(:each) do
    Garner.config.cache.clear
  end
end
