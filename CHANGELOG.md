0.4.4 (7/11/2013)
-----------------
* Fixed [#47](https://github.com/artsy/garner/issues/47): use a database index when generating proxy binding in `Garner::Mixins::Mongoid::Identity` with multiple `Garner.config.mongoid_identity_fields` - [@dblock](https://github.com/dblock).

0.4.3 (7/5/2013)
----------------
* Stored `ruby_context` from which a `Garner::Cache::Identity` was initialized as an `attr_accessor` on the object - [@fancyremarker](https://github.com/fancyremarker).
* Fixed `cache_enabled?` logic and added a `nocache` declaration to `Garner::Cache::Identity` - [@fancyremarker](https://github.com/fancyremarker).
* Fixed #44, in which the BindingIndex was mistakenly storing values to cache for bindings with a nil canonical binding - [@fancyremarker](https://github.com/fancyremarker).
* Added `Garner.config.invalidate_mongoid_root` option, to always invalidate the root document when an embedded document is invalidated - [@fancyremarker](https://github.com/fancyremarker).

0.4.2 (6/28/2013)
-----------------
* Fixed `Caller` strategy when using Rails - [@fancyremarker](https://github.com/fancyremarker).

0.4.1 (6/28/2013)
-----------------
* Added a `rake benchmark` task to compare different binding key/invalidation strategy pairs - [@fancyremarker](https://github.com/fancyremarker).
* Improved the performance of the `SafeCacheKey` strategy on virtual `Garner::Mixins::Mongoid::Identity` bindings by properly memoizing the corresponding document - [@fancyremarker](https://github.com/fancyremarker).
* Improved the performance of the `SafeCacheKey` strategy on class bindings by making 1 database call per key application, instead of 3 - [@fancyremarker](https://github.com/fancyremarker).
* Removed the `Garner.config.mongoid_binding_key_strategy` and `Garner.config.mongoid_invalidation_key_strategy`. Garner now uses just one default key/invalidation strategy pair for all binding types - [@fancyremarker](https://github.com/fancyremarker).
* Added an ActiveRecord mixin, `Garner::Mixins::ActiveRecord::Base`, per #35 - [@fancyremarker](https://github.com/fancyremarker).
* Eliminated the need to `require "garner/mixins/rack"` before declaring `Garner.config.rack_context_key_strategies`, per #35 - [@fancyremarker](https://github.com/fancyremarker).
* Fixed a bug in binding to classes via the `SafeCacheKey` and `Touch` strategy pair, where class-bound results would not be invalidated when an instance of the class was destroyed - [@fancyremarker](https://github.com/fancyremarker).
* Added `BindingIndex` binding key/invalidation strategy pair, which uses a two-level lookup for computing cache keys - [@fancyremarker](https://github.com/fancyremarker).

0.4.0 (6/14/2013)
-----------------

* Complete rewrite of Garner. See [UPGRADING](UPGRADING.md) for details on how to upgrade from Garner 0.3.3 and earlier versions - [@fancyremarker](https://github.com/fancyremarker).
* Fixed #6: Garner fails if Mongoid not loaded yet - [@fancyremarker](https://github.com/fancyremarker).
* Closed #12: Support arrays in `Garner.config.mongoid_identity_fields`- [@fancyremarker](https://github.com/fancyremarker).
* Closed #13: Replace faulty multiple-identity logic- [@fancyremarker](https://github.com/fancyremarker).
* Fixed #14: Disambiguate binding models by `:id` and `:slug`- [@fancyremarker](https://github.com/fancyremarker).
* Fixed #15: Remove need for `cache_as` from subclassed Mongoid models - [@fancyremarker](https://github.com/fancyremarker).
* Closed #23: Abstract all Grape mixins to be more generically Rack mixins - [@fancyremarker](https://github.com/fancyremarker).
* Closed #24: Implement `garnered_find` method for `Mongoid::Document` classes - [@fancyremarker](https://github.com/fancyremarker).
* Extracted `Binding`, `Context` and `Identity` as explicit classes from `ObjectIdentity` - [@fancyremarker](https://github.com/fancyremarker).
* Added support for all ActiveModel-compliant ORMs - [@fancyremarker](https://github.com/fancyremarker).
* Removed HTTP caching responsibilities from the library entirely - [@fancyremarker](https://github.com/fancyremarker).
* Introduced a `SafeCacheKey` binding key strategy, which appends subsecond precision to cache keys, to make them usable - [@fancyremarker](https://github.com/fancyremarker).
* Added a `cache_key` implementation at the class level in Mongoid, which returns the `cache_key` of the most recently updated document in the collection (by `:updated_at`) - [@fancyremarker](https://github.com/fancyremarker).
* Fixed #29: Restrict the filename string used for the `Caller` context key strategy to just the portion of the path relevant to the current app. In a Rails app, this defaults to Rails.root; otherwise we search for the nearest ancestor directory containing a Gemfile - [@fancyremarker](https://github.com/fancyremarker).

0.3.3 (6/10/2013)
-----------------

* Fix: parent documents are properly invalidated on creation of an embedded document - [@fancyremarker](https://github.com/fancyremarker).

0.3.2 (5/16/2013)
-----------------

* Fix: calling `invalidate` on an embedded document in an `embeds_many` relationship - [@fancyremarker](https://github.com/fancyremarker).
* `Garner::Strategies::Keys::Caller` no longer depends on ActiveSupport - [@oripekelman](https://github.com/oripekelman), [@dblock](https://github.com/dblock).
* Added `Garner::Strategies::Keys::RequestPost` for POST parameters - [@oripekelman](https://github.com/oripekelman).

0.3.1
-----

* Do not attempt to fetch again objects in `Garner::Cache::ObjectIdentity.cache_multi` after they were not retrieved from `read_multi`, write them directly to cache - [@dblock](https://github.com/dblock).

0.3
---

* Added `Garner::Cache::ObjectIdentity.cache_multi` that can now take an array of bindings to return an array of objects - [@dblock](https://github.com/dblock).
* When fetching an array of objects via `Garner::Cache::ObjectIdentity.cache_multi`, Garner will use `read_multi` if provided by the cache store - [@dblock](https://github.com/dblock).

0.2.1
-----

* Faster invalidation on Mongoid model creation, only invalidate class - [@dblock](https://github.com/dblock).
* Invalidate cache after a Mongoid model has been updated or destroyed, not before - [@dblock](https://github.com/dblock).

0.2
---

* The `Keys::Caller` strategy now allows specifying the caller explicitly by passing a `:caller` as part of the context - [@fancyremarker](https://github.com/fancyremarker).
* Fix: `invalidate` no longer writes a new index key for each object binding; instead it only deletes existing index keys - [@fancyremarker](https://github.com/fancyremarker).
* Fix: Invoking Garner helper methods from within an IRB session no longer crashes inside the `Keys::Caller` strategy - [@fancyremarker](https://github.com/fancyremarker).

0.1.3
-----

* Split `Garner::Objects::ETag` into a configurable `Garner::Strategies::ETags` module, making `Garner::Strategies::ETags::GrapeETag` the new default, for better integration with Grape - [@fancyremarker](https://github.com/fancyremarker).
* Added `Garner::Strategies::Keys::Key`, that inserts the value of `:key` within the requested context, useful to explicitly declare an element of a cache key - [@dblock](https://github.com/dblock).
* Fix: `Garner::Strategies::Keys::Caller` excludes lines with `lib/garner`, workaround for Heroku - [@dblock](https://github.com/dblock).
* Only load Grape and Mongoid mixins when necessary - [@billgloff](https://github.com/billgloff).
* Fix: Grape API version is properly passed through to key context when using `Garner::Strategies::Keys::Version` - [@fancyremarker](https://github.com/fancyremarker).
* Added support for caching responses to JSONP requests, via `Garner::Strategies::Keys::Jsonp` - [@fancyremarker](https://github.com/fancyremarker).

0.1.2
-----

* Fix: `Garner::Mixins::Grape::Cache` improperly handles `nil` cache hits or `cache_enabled?` returning `false` in `cache_or_304` - [@dblock](https://github.com/dblock).

0.1.1
-----

* Initial public release at [GoRuCo](http://goruco.com), read the [announcement](http://artsy.github.com/blog/2012/05/30/restful-api-caching-with-garner/).
* Grape mixin takes a single parameter, binding and context are extracted from it - [@dblock](https://github.com/dblock).

0.1
---

* Initial implementation based on [@fancyremarker](https://github.com/fancyremarker)'s original code.
* Rack middleware for cache busting, `Garner::Middleware::Cache::Bust` - [@dblock](https://github.com/dblock).
* Generating ETags, `Garner::Objects::ETag` - [@dblock](https://github.com/dblock).
* `Garner::Cache::ObjectIdentity` cache - [@dblock](https://github.com/dblock).
* `Version`, `Caller`, `RequestPath` and `RequestGet` key generation strategies - [@dblock](https://github.com/dblock).
* `Expiration` cache strategy - [@dblock](https://github.com/dblock).
* [Grape](https://github.com/intridea/grape) and [Mongoid](https://github.com/mongoid/mongoid/) mixins - [@dblock](https://github.com/dblock).
