Garner [![Build Status](https://secure.travis-ci.org/artsy/garner.png)](http://travis-ci.org/artsy/garner) [![Dependency Status](https://gemnasium.com/artsy/garner.png)](https://gemnasium.com/artsy/garner)
======

Garner is a cache layer for Ruby and Rack applications, supporting model and instance binding and hierarchical invalidation. To "garner" means to gather data from various sources and to make it readily available in one place, kind of like a cache!

Usage
-----

### Application Logic Caching

Add Garner to your Gemfile with `gem "garner"` and run `bundle install`. Include the Rack mixin in your application. For Grape, this could be done like so:

```ruby
class API < Grape::API
  helpers Garner::Mixins::Rack
end
```

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

But what if you want to bind a cache result to a persisted object that hasn't been retrieved yet? Consider the example of caching a particular order without a database query:

```ruby
get "/order/:id" do
  # Invalidate when Order.find(params[:id]) is modified
  garner.bind(Order.identify(params[:id])) do
    Order.find(params[:id])
  end
end
```

In the above example, the `Order.identify` call will not result in a database query. Instead, it just communicates to Garner's cache sweeper that whenever the order with identity `params[:id]` is updated, this cache result should be invalidated.

### Caching Persisted Objects

Garner provides helper methods for cached `find` operations in Mongoid. To use, just include the Mongoid mixin with the following code snippet, which can go in an initializer:

``` ruby
module Mongoid
  module Document
    include Garner::Mixins::Mongoid::Document
  end
end
```

Now, we can use the following code to fetch an order by ID once from the database, and then from the cache on subsequent requests. The cache will be invalidated whenever the underlying persisted object changes in the database.

```ruby
order = Order.garnered_find(3)
```


Under The Hood: Bindings
------------------------

As we've seen, a cache result can be bound to a model instance (e.g., `current_user`) or a virtual instance reference (`Order.identify(params[:id])`). It can also be bound to an entire model class. In this case, whenever any order is created, updated or deleted, the cache result will be invalidated:

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

We can compose bindings, too:

```ruby
get "/system/counts/all" do
  # Invalidate when any order or user is modified
  # (Equivalent to `garner.bind(Order, User)`)
  garner.bind(Order).bind(User) do
    {
      "orders_count" => Order.count,
      "users_count"  => User.count
    }
  end
end
```

In the first route above, the cache result will be invalidated whenever the order with identity `params[:order_id]` and belonging to a user with identity `params[:user_id]` is updated. In the second route, the cache result will be invalidated whenever *any order* belonging to that user is updated.


Under The Hood: Cache Keys
--------------------------

Explicit cache keys are usually unnecessary in Garner. Given a cache binding, Garner will compute an appropriately unique cache key. Moreover, in the context of `Garner::Mixins::Rack`, Garner will compose the following key factors by default:

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

As with cache bindings, key factors may be composed by calling `key()` multiple times on a `garner` invocation. The keys will be applied in the order in which they are called.


Under The Hood: Invalidation
----------------------------

Invalidation can be triggered programmatically by calling `invalidate_garner_cache` on a model class or instance. Both of the following invocations will work:

```ruby
Order.invalidate_garner_cache
Order.find(3).invalidate_garner_cache
```

The application is responsible for ensuring invalidation on create, update and save actions. Garner currently provides a [Mongoid](https://github.com/mongoid/mongoid) mixin, which does exactly this. Extend `Mongoid::Document` as follows (e.g., in `config/initializers/mongoid_document.rb`).

``` ruby
module Mongoid
  module Document
    include Garner::Mixins::Mongoid::Document
  end
end
```

Please contribute invalidation mixins for other ORMs, like ActiveRecord!


Configuration
-------------

By default `Garner` will use an instance of `ActiveSupport::Cache::MemoryStore` in a non-Rails and `Rails.cache` in a Rails environment. You can configure it to use any other cache store.

``` ruby
Garner.configure do |config|
  config.cache = ActiveSupport::Cache::FileStore.new
end
```


Contributing
------------

Fork the project. Make your feature addition or bug fix with tests. Send a pull request.

Copyright and License
---------------------

MIT License, see [LICENSE](https://github.com/dblock/garner/blob/master/LICENSE.md) for details.

(c) 2012 [Art.sy Inc.](http://artsy.github.com), [Frank Macreery](https://github.com/macreery), [Daniel Doubrovkine](https://github.com/dblock) and [Contributors](https://github.com/dblock/garner/blob/master/CHANGELOG.md)

