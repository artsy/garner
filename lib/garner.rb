require 'multi_json'
require 'active_support'
# garner
require 'garner/version'
require 'garner/config'
# key strategies
require 'garner/strategies/keys/caller_strategy'
require 'garner/strategies/keys/request_path_strategy'
require 'garner/strategies/keys/request_get_strategy'
require 'garner/strategies/keys/request_post_strategy'
require 'garner/strategies/keys/jsonp_strategy'
# cache option strategies
require 'garner/strategies/cache/expiration_strategy'
# caches
require 'garner/cache/object_identity'
# mixins
require 'garner/mixins/rack'
require 'garner/mixins/mongoid_document' if defined?(Mongoid)
