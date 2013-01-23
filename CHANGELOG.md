Next Release
------------
* `Garner::Cache::ObjectIdentity.cache` can now take an array of bindings to return an array of objects - [@dblock](https://github.com/dblock).
* When fetching an array of objects via `Garner::Cache::ObjectIdentity.cache`, Garner will use `read_multi` if provided by the cache store - [@dblock](https://github.com/dblock).

0.2.1
-----
* Faster invalidation on Mongoid model creation, only invalidate class - [@dblock](https://github.com/dblock).
* Invalidate cache after a Mongoid model has been updated or destroyed, not before - [@dblock](https://github.com/dblock).

0.2
---

* The `Keys::Caller` strategy now allows specifying the caller explicitly by passing a `:caller` as part of the context - [@macreery](https://github.com/macreery).
* Fix: `invalidate` no longer writes a new index key for each object binding; instead it only deletes existing index keys - [@macreery](https://github.com/macreery).
* Fix: Invoking Garner helper methods from within an IRB session no longer crashes inside the `Keys::Caller` strategy - [@macreery](https://github.com/macreery).

0.1.3
-----

* Split `Garner::Objects::ETag` into a configurable `Garner::Strategies::ETags` module, making `Garner::Strategies::ETags::GrapeETag` the new default, for better integration with Grape - [@macreery](https://github.com/macreery).
* Added `Garner::Strategies::Keys::Key`, that inserts the value of `:key` within the requested context, useful to explicitly declare an element of a cache key - [@dblock](https://github.com/dblock).
* Fix: `Garner::Strategies::Keys::Caller` excludes lines with `lib/garner`, workaround for Heroku - [@dblock](https://github.com/dblock).
* Only load Grape and Mongoid mixins when necessary - [@billgloff](https://github.com/billgloff).
* Fix: Grape API version is properly passed through to key context when using `Garner::Strategies::Keys::Version` - [@macreery](https://github.com/macreery).
* Added support for caching responses to JSONP requests, via `Garner::Strategies::Keys::Jsonp` - [@macreery](https://github.com/macreery).

0.1.2
-----

* Fix: `Garner::Mixins::Grape::Cache` improperly handles `nil` cache hits or `cache_enabled?` returning `false` in `cache_or_304` - [@dblock](https://github.com/dblock).

0.1.1
-----

* Initial public release at [GoRuCo](http://goruco.com), read the [announcement](http://artsy.github.com/blog/2012/05/30/restful-api-caching-with-garner/).
* Grape mixin takes a single parameter, binding and context are extracted from it - [@dblock](https://github.com/dblock).

0.1
---

* Initial implementation based on [@macreery](https://github.com/macreery)'s original code.
* Rack middleware for cache busting, `Garner::Middleware::Cache::Bust` - [@dblock](https://github.com/dblock).
* Generating ETags, `Garner::Objects::ETag` - [@dblock](https://github.com/dblock).
* `Garner::Cache::ObjectIdentity` cache - [@dblock](https://github.com/dblock).
* `Version`, `Caller`, `RequestPath` and `RequestGet` key generation strategies - [@dblock](https://github.com/dblock).
* `Expiration` cache strategy - [@dblock](https://github.com/dblock).
* [Grape](https://github.com/intridea/grape) and [Mongoid](https://github.com/mongoid/mongoid/) mixins - [@dblock](https://github.com/dblock).
