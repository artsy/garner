require "multi_json"
require "active_support"

# Garner core
require "garner/version"
require "garner/config"

# Key strategies
require "garner/strategies/context_key/caller"
require "garner/strategies/context_key/request_path"
require "garner/strategies/context_key/request_get"
require "garner/strategies/context_key/request_post"
require "garner/strategies/context_key/jsonp"

# Binding strategies
require "garner/strategies/binding_key/cache_key"

# Cache
require "garner/cache"
require "garner/cache/identity"
require "garner/cache/context"
require "garner/cache/binding"

# Third-party mixins
require "garner/mixins/rack"
require "garner/mixins/mongoid_document" if defined?(Mongoid)
