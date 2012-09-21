Garner [![Build Status](https://secure.travis-ci.org/artsy/garner.png)](http://travis-ci.org/artsy/garner)
======

Garner is a practical Rack-based cache implementation for RESTful APIs with support for HTTP 304 Not Modified based on time and ETags, model and instance binding and hierarchical invalidation. Garner is currently targeted at [Grape](https://github.com/intridea/grape), other systems may need some work.

To "garner" means to gather data from various sources and to make it readily available in one place, kind-of like a cache!

Usage
-----

Add Garner to Gemfile with `gem "garner"` and run `bundle install`. Include the Garner mixin into your API. Currently Grape is supported out of the box. It's also recommended to prevent clients from caching dynamic data by default using the `Garner::Middleware::Cache::Bust` middleware. See below for a detailed explanation.

```ruby
class API < Grape::API
  use Garner::Middleware::Cache::Bust
  helpers Garner::Mixins::Grape::Cache
end
```

To cache a value, invoke `cache` from within your API. Without any parameters it generates a key based on the source code location, request parameters and path, and stores the value in the cache configured as `Garner.config.cache`. The cache is automatically `Rails.cache` when mounted in Rails and an instance of `ActiveSupport::Cache::MemoryStore` otherwise.

``` ruby
get "/" do
  cache do
    { :counter => 42 }
  end
end
```

To enable support for the date-based `If-Modified-Since` and the ETag-based `If-None-Match`, use `cache_or_304`. If the data hasn't changed, the API will return `304 Not Modified` without a cache miss. For example, if the inside of a cached block is a database query, it will not be executed the second time. This is possible because Garner stores an entry for every cache binding with the last-modified timestamp and ETag.

``` ruby
get "/" do
  cache_or_304 do
    { :counter => 42 }
  end
end
```

The cached value can also be bound to other models. For example, if a user has an address that may or may not change when the user is saved, you will want the cached address to be invalidated every time the user record changes.

``` ruby
get "/me/address" do
  cache_or_304({ :bind => [ User, current_user.id ] }) do
    current_user.address
  end
end
```

ETag Generation Strategies
--------------------------

The primary purpose of the ETag header is to define a short string representation of a cached object that is both (a) deterministic and (b) unique, so that Garner's `cache_or_304` method can quickly determine whether a client's cached content matches the latest server object. As such, an MD5 hash applied to *any* object serialization would suffice. However, some applications may wish to control the manner in which ETags are generated, and so Garner supports arbitrary ETag strategies.

The default strategy, `Garner::Strategies::ETags::Grape`, follows the serialization strategy used by Grape for coercing objects into JSON. Using this strategy, Garner will generate an ETag for each cache object that is identical to what `Rack::ETag` would return if that object was returned by Grape. This property could be useful for Grape applications.

Another, simpler strategy, `Garner::Strategies::ETags::Marshal`, simply applies an MD5 hash to `Marshal.dump(object)`. This strategy might be more applicable for applications not using Grape.

An ETag strategy may be defined at application startup time:

```
ETAG_STRATEGY = Garner::Strategies::ETags::Grape
```


Binding Strategies
------------------

The binding parameter can be an object, class, array of objects, or array of classes on which to bind the validity of the cached result contained in the subsequent block. If no bind argument is specified, the subsequent block result will remain valid until it expires due to natural causes (e.g., passage of default memcached expiry, or memcached overflow). Here are some examples of how to use the bind option.

* `bind: { klass: Widget, object: { id: params[:id] } }` will cause the subsequent block result to be invalidated on any change to the `Widget` object whose `id` attribute equals `params[:id]`.
* `bind: { klass: User, object: { id: current_user.id } }` will cause the subsequent block result to be invalidated on any change to the `User` object whose `id` attribute equals `current_user.id`. This is one way to bind a cache result to any change in the current user.
* `bind: { klass: Widget }` will cause the subsequent block result to be invalidated on any change to any object of class `Widget`. This is the appropriate strategy for index paths like `/widgets`.
* `bind: [{ klass: Widget }, { klass: User, object: { id: current_user.id } }]` will cause the subsequent block result to be invalidated on any change to either the current user, or any object of class `Widget`.

Bind supports some nice shorthands.

* `bind: [Widget]` is shorthand for `bind: { klass: Widget }`
* `bind: [Widget, params[:id]]` is shorthand for `bind: { klass: Widget, object: { id: params[:slug] } }`
* `bind: [User, { id: current_user.id }]` is shorthand for `bind: { klass: User, object: { id: current_user.id } }`
* `bind: [[Widget], [User, { id: current_user.id }]]` is shorthand for `bind: [{ klass: Widget }, { klass: User, object: { id: current_user.id } }]`

Invalidation
------------

You must take care of data invalidation on save. Garner currently includes a mixin with support for [Mongoid](https://github.com/mongoid/mongoid). Extend `Mongoid::Document` as follows (eg. in `config/initializers/mongoid_document.rb`).

``` ruby
module Mongoid
  module Document
    include Garner::Mixins::Mongoid::Document
  end
end
```

Please contribute other invalidation mixins.

Role-Based Caching
------------------

Role-Based caching is a subset of the generic problem of binding data to groups of other objects. For example, a `Widget` may have a different representation for an `admin` vs. a `user`. In Garner you can inject something called a "key strategy" into the current key generation pipeline. A strategy is a plain module that must implement two methods: `apply` and `field`. The former applies a strategy to a key within a context and the latter is a unique name that is produced by the strategy.

The following example introduces the role of the current user into the cache key.

``` ruby
module MyApp
  module Garner
    module RoleStrategy
      class << self
        def field
          :role
        end
        def apply(key, context = {})
          key = key ? key.dup : {}
          key[:role] = current_user.role
          key
        end
      end
    end
  end
end
```

Garner key strategies are applied in order and can be currently set at application startup time.

```
Garner::Cache::ObjectIdentity::KEY_STRATEGIES = [
  Garner::Strategies::Keys::Caller, # support multiple calls from the same function
  MyApp::Garner::RoleStrategy, # custom strategy for role-based access
  Garner::Strategies::Keys::RequestPath # injects the HTTP request's URL
]
```

This method of registration does need improvement, please contribute.

Available Key Strategies
------------------------

* `Garner::Strategies::Keys::Caller` inserts the calling file and line number, allowing multiple calls from the same function to generate different keys. The caller can be specified explicitly by passing a value for `:caller` in the requesting context.
* `Garner::Strategies::Keys::Version` inserts the output of a `version` method, when available, primarily targeted at API implementations.
* `Garner::Strategies::Keys::Key` inserts the value of `:key` within the requested context, useful to explicitly declare an element of a cache key.
* `Garner::Strategies::Keys::RequestGet` inserts the value of HTTP request's GET parameters into the cache key when `:request` is present in the context.
* `Garner::Strategies::Keys::RequestPath` inserts the value of the HTTP request's path into the cache key when `:request` is present in the context.

Configuration
-------------

By default `Garner` will use an instance of `ActiveSupport::Cache::MemoryStore` in a non-Rails and `Rails.cache` in a Rails environment. You can configure it to use any other cache store.

``` ruby
Garner.configure do |config|
  config.cache = ActiveSupport::Cache::FileStore.new
end
```

Preventing Clients from Caching Dynamic Data
--------------------------------------------

Generally, dynamic data cannot have a well-defined expiration time. Therefore, we must tell the client not to cache it. This can be accomplished using the `Garner::Middleware::Cache::Bust` middleware, executed after any API call. The middleware adds a `Cache-Control` and an `Expires` header.

```
Cache-Control: private, max-age=0, must-revalidate
Expires: Fri, 01 Jan 1990 00:00:00 GMT
```

The `private` option of the `Cache-Control` header instructs the client that it is allowed to store data in a private cache (unnecessary, but is known to work around overzealous cache implementations), `max-age` that it must check with the server every time it needs this data and `must-revalidate` prevents gateways from returning a response if your API server is unreachable. An additional `Expires` header will make double-sure the entire request expires immediately.

Contributing
------------

Fork the project. Make your feature addition or bug fix with tests. Send a pull request. Bonus points for topic branches.

Copyright and License
---------------------

MIT License, see [LICENSE](https://github.com/dblock/garner/blob/master/LICENSE.md) for details.

(c) 2012 [Art.sy Inc.](http://artsy.github.com), [Frank Macreery](https://github.com/macreery), [Daniel Doubrovkine](https://github.com/dblock) and [Contributors](https://github.com/dblock/garner/blob/master/CHANGELOG.md)

