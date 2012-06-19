Garner [![Build Status](https://secure.travis-ci.org/dblock/garner.png)](http://travis-ci.org/dblock/garner)
======

Garner is a set of Rack middleware and cache helpers that implement various cachin;.   strategies.

Caching Dynamic Data
--------------------

Caching dynamic data can be a bit involved. Let's begin with a simple Ruby API that returns a counter.

``` ruby
class API < Grape::API
  def count
    { count : 0 }
  end
end
```

This kind of dynamic data cannot have a well-defined expiration time. The counter may be incremented at any time via another API call or process. therefore, we must tell the client not to cache it. This is accomplished using the `Garner::Middleware::Cache::Bust` middleware, executed after any API call. The middleware adds a `Cache-Control` and an `Expires` header. 

```
Cache-Control: private, max-age=0, must-revalidate
Expires: Fri, 01 Jan 1990 00:00:00 GMT
```

The `private` option of the `Cache-Control` header instructs the client that it is allowed to store data in a private cache (unnecessary, but is known to work around overzealous cache implementations), `max-age` that it must check with the server every time it needs this data and `must-revalidate` prevents gateways from returning a response if your API server is unreachable. An additional `Expires` header will make double-sure the entire request expires immediately.

Generating ETags
----------------

A client may want to retrieve the value of the counter and runs a job every time the value changes. As it stands, the current API requires an effort on the client's part to remember the previous value and compare it every time it makes an API call. This can be avoided by asking the server for a new counter if the value has changed. 

One possibility is to include an `If-Modified-Since` header with a timestamp. The server could respond with `304 Not Modified` if the counter hasn't changed since it was last requested. While this may be acceptable for certain data, timestamps have a granularity of seconds. A counter may be modified multiple times during the same second, therefore preventing it from retrieving the result of the second modification.

A more robust solution is to generate a unique signature, called ETag, for this data and to use it to find out whether the counter has changed. The implementation of `Garner::Objects::ETag` matches the one of the existing `Rack::ETag` middleware.

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

Fork the project. Make your feature addition or bug fix with tests. Send a pull request. Bonus points for topic branches.

Copyright and License
---------------------

MIT License, see [LICENSE](https://github.com/dblock/garner/blob/master/LICENSE.md) for details.

(c) 2012 [Art.sy Inc.](http://artsy.github.com) and [Contributors](https://github.com/dblock/garner/blob/master/CHANGELOG.md)

