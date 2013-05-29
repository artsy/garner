require "multi_json"
require "active_support"

# Garner core
require "garner/version"
require "garner/config"

# Key strategies
require "garner/strategies/keys/caller"
require "garner/strategies/keys/request_path"
require "garner/strategies/keys/request_get"
require "garner/strategies/keys/request_post"
require "garner/strategies/keys/jsonp"

# Cache
require "garner/cache"
require "garner/cache/identity"
require "garner/cache/context"

# Binding strategies
require "garner/strategies/bindings/single_identity"
require "garner/strategies/bindings/indexed_identities"
require "garner/strategies/bindings/declared_identities"

# Third-party mixins
require "garner/mixins/rack"
require "garner/mixins/mongoid_document" if defined?(Mongoid)
