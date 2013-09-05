Garner [![Build Status](https://secure.travis-ci.org/artsy/garner.png)](http://travis-ci.org/artsy/garner) [![Dependency Status](https://gemnasium.com/artsy/garner.png)](https://gemnasium.com/artsy/garner) [![Coverage Status](https://coveralls.io/repos/artsy/garner/badge.png)](https://coveralls.io/r/artsy/garner) [![Code Climate](https://codeclimate.com/github/artsy/garner.png)](https://codeclimate.com/github/artsy/garner)
======

Garner is a cache layer for Ruby and Rack applications, supporting model and instance binding and hierarchical invalidation. To "garner" means to gather data from various sources and to make it readily available in one place, kind of like a cache!

If you're not familiar with HTTP caching, ETags and If-Modified-Since, watch us introduce Garner in [From Zero to API Cache in 10 Minutes](http://www.confreaks.com/videos/986-goruco2012-from-zero-to-api-cache-w-grape-mongodb-in-10-minutes) at GoRuCo 2012.

Upgrading
---------

The current stable release line of Garner is 0.4.x, and contains many breaking changes from the previous 0.3.x series. For a summary of important changes, see [UPGRADING](UPGRADING.md).

Usage
-----

### Application Logic Caching

Add Garner to your Gemfile with `gem "garner"` and run `bundle install`. Next, include the appropriate mixin in your app:

* For plain-old Ruby apps, `include Garner::Cache::Context`.
* For Rack apps, first `require "garner/mixins/rack"`, then `include Garner::Mixins::Rack`. (This provides saner defaults for injecting request parameters into the cache context key. More on cache context keys later.)

Now, to use Garner's cache, invoke `garner` with a logic block from within your application. The result of the block will be computed once, and then stored in the cache.

``` ruby
get "/system/counts/all" do
  # Compute once and cache for subsequent reads
  garner do
    {
      "orders_count" => Order.count,
      "users_count"  => User.count
    }
  end
end
```

The cached value can be bound to a particular model instance. For example, if a user has an address that may or may not change when the user is saved, you will want the cached address to be invalidated every time the user record is modified.

``` ruby
get "/me/address" do
  # Invalidate when current_user is modified
  garner.bind(current_user) do
    current_user.address
  end
end
```


ORM Integrations
----------------

### Mongoid

To use Mongoid documents and classes for Garner bindings, use `Garner::Mixins::Mongoid::Document`. You can set it up in an initializer:

``` ruby
require "garner/mixins/mongoid"

module Mongoid
  module Document
    include Garner::Mixins::Mongoid::Document
  end
end
```

This enables binding to Mongoid classes as well as instances. For example:

```ruby
get "/system/counts/orders" do
  # Invalidate when any order is created, updated or deleted
  garner.bind(Order) do
    {
      "orders_count" => Order.count,
    }
  end
end
```

What if you want to bind a cache result to a persisted object that hasn't been retrieved yet? Consider the example of caching a particular order without a database query:

```ruby
get "/order/:id" do
  # Invalidate when Order.find(params[:id]) is modified
  garner.bind(Order.identify(params[:id])) do
    Order.find(params[:id])
  end
end
```

In the above example, the `Order.identify` call will not result in a database query. Instead, it just communicates to Garner's cache sweeper that whenever the order with identity `params[:id]` is updated, this cache result should be invalidated. The `identify` method is provided by the Mongoid mixin. To use it, you should configure `Garner.config.mongoid_identity_fields`, e.g.:

```ruby
Garner.configure.do |config|
  config.mongoid_identity_fields = [:_id, :_slugs]
end
```

These may be scalar or array fields. Only uniquely-constrained fields should be used here; otherwise you risk caching the same result for two different blocks.

The Mongoid mixin also provides helper methods for cached `find` operations. The following code will fetch an order once (via `find`) from the database, and then fetch it from the cache on subsequent requests. The cache will be invalidated whenever the underlying `Order` changes in the database.

```ruby
order = Order.garnered_find(3)
```

Explicit invalidation should be unnecessary, since callbacks are declared to invalidate the cache whenever a Mongoid object is created, updated or destroyed, but for special cases, `invalidate_garner_caches` may be called on a Mongoid object or class:

```ruby
Order.invalidate_garner_caches
Order.find(3).invalidate_garner_caches
```

### ActiveRecord

Garner provides rudimentary support for `ActiveRecord`. To use ActiveRecord models for Garner bindings, use `Garner::Mixins::ActiveRecord::Base`. You can set it up in an initializer:

``` ruby
require "garner/mixins/active_record"

module ActiveRecord
  class Base
    include Garner::Mixins::ActiveRecord::Base
  end
end
```

Cache Options
-------------

You can pass additional options directly to the cache implementation:

``` ruby
get "/latest_order" do
  # Expire the latest order every 15 minutes
  garner.options(expires_in: 15.minutes) do
    Order.latest
  end
end
```

Under The Hood: Bindings
------------------------

As we've seen, a cache result can be bound to a model instance (e.g., `current_user`) or a virtual instance reference (`Order.identify(params[:id])`). In some cases, we may want to compose bindings:

```ruby
get "/system/counts/all" do
  # Invalidate when any order or user is modified
  garner.bind(Order).bind(User) do
    {
      "orders_count" => Order.count,
      "users_count"  => User.count
    }
  end
end
```

Binding keys are computed via pluggable strategies, as are the rules for invalidating caches when a binding changes. By default, Garner uses `Garner::Strategies::Binding::Key::SafeCacheKey` to compute binding keys: this uses `cache_key` if defined on an object; otherwise it always bypasses cache. Similarly, Garner uses `Garner::Strategies::Binding::Invalidation::Touch` as its default invalidation strategy. This will call `:touch` on a document if it is defined; otherwise it will take no action.

Additional binding and invalidation strategies can be written. To use them, set `Garner.config.binding_key_strategy` and `Garner.config.binding_invalidation_strategy`.


Under The Hood: Cache Context Keys
----------------------------------

Explicit cache context keys are usually unnecessary in Garner. Given a cache binding, Garner will compute an appropriately unique cache key. Moreover, in the context of `Garner::Mixins::Rack`, Garner will compose the following key factors by default:

* `Garner::Strategies::Context::Key::Caller` inserts the calling file and line number, allowing multiple calls from the same function to generate different results.
* `Garner::Strategies::Context::Key::RequestGet` inserts the value of HTTP request's GET parameters into the cache key when `:request` is present in the context.
* `Garner::Strategies::Context::Key::RequestPost` inserts the value of HTTP request's POST parameters into the cache key when `:request` is present in the context.
* `Garner::Strategies::Context::Key::RequestPath` inserts the value of the HTTP request's path into the cache key when `:request` is present in the context.

Additional key factors may be specified explicitly using the `key` method. To see a specific example of this in action, let's consider the case of role-based caching. For example, an order may have a different representation for an admin versus an ordinary user:

```ruby
get "/order/:id" do
  garner.bind(Order.identify(params[:id])).key({ role: current_user.role }) do
    Order.find(params[:id])
  end
end
```

As with bindings, context key factors may be composed by calling `key()` multiple times on a `garner` invocation. The keys will be applied in the order in which they are called.


Configuration
-------------

By default `Garner` will use an instance of `ActiveSupport::Cache::MemoryStore` in a non-Rails and `Rails.cache` in a Rails environment. You can configure it to use any other cache store.

``` ruby
Garner.configure do |config|
  config.cache = ActiveSupport::Cache::FileStore.new
end
```

The full list of  `Garner.config` attributes is:

* `:global_cache_options`: A hash of options to be passed on every call to `Garner.config.cache`, like `{ :expires_in => 10.minutes }`. Defaults to `{}`
* `:context_key_strategies`: An array of context key strategies, to be applied in order. Defaults to `[Garner::Strategies::Context::Key::Caller]`
* `:rack_context_key_strategies`: Rack-specific context key strategies. Defaults to:
```ruby
[
  Garner::Strategies::Context::Key::Caller,
  Garner::Strategies::Context::Key::RequestGet,
  Garner::Strategies::Context::Key::RequestPost,
  Garner::Strategies::Context::Key::RequestPath
]
```
* `:binding_key_strategy`: Binding key strategy. Defaults to `Garner::Strategies::Binding::Key::SafeCacheKey`.
* `:binding_invalidation_strategy`: Binding invalidation strategy. Defaults to `Garner::Strategies::Binding::Invalidation::Touch`.
* `:mongoid_identity_fields`: Identity fields considered legal for the `identity` method. Defaults to `[:_id]`.
* `:caller_root`: Root path of application, to be stripped out of value strings generated by the `Caller` context key strategy. Defaults to `Rails.root` if in a Rails environment; otherwise to the nearest ancestor directory containing a Gemfile.
* `:invalidate_mongoid_root`: If set to true, invalidates the `_root` document along with any embedded Mongoid document binding. Defaults to `true`.

Contributing
------------

Fork the project. Make your feature addition or bug fix with tests. Send a pull request.

Copyright and License
---------------------

MIT License, see [LICENSE](LICENSE.md) for details.

(c) 2012-2013 [Artsy](http://artsy.github.com), [Frank Macreery](https://github.com/fancyremarker), [Daniel Doubrovkine](https://github.com/dblock) and [contributors](CHANGELOG.md).

