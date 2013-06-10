Upgrading
=========

From <= 0.3.3 to 0.4.0
----------------------

### Binding Strategies

The API for declaring cache bindings has changed completely. Instead of passing a hash to `cache`, you may now call `bind` on the `garner` method. `bind` takes an explicit object as its argument. So, for example:

```ruby
cache({ bind: [ User, current_user.id ] }) do
  current_user.address
end
```

now becomes:
```ruby
garner.bind(current_user) do
  current_user.address
end
```

To accommodate virtual object bindings (object references by class name and ID alone), Garner 0.4.0 provides an `identify` method as part of its Mongoid mixin. So,

```ruby
cache({ :bind => [Widget, params[:id]] }) { }
```

now becomes:

```ruby
garner.bind(Widget.identify(params[:id]))
```

Please consult the following table for translations from all documented pre-0.4.0 Garner bindings:

| 0.3.3 Binding | 0.4.0 Binding |
|---------------|---------------|
| `bind: { klass: Widget, object: { id: params[:id] } }` | `bind(Widget.identify(id))` |
| `bind: { klass: Widget }` | `bind(Widget)` |
| `bind: [Widget]` | `bind(Widget)` |
| `bind: [Widget, params[:id]]` | `bind(Widget.identify(params[:id]))` |
| `bind: [User, { id: current_user.id }]` | `bind(current_user)` |
| `bind: [[Widget], [User, { id: current_user.id }]]` | `bind(Widget).bind(current_user)` |

### Grape Integration

With Garner 0.4.0, a single Rack mixin provides all necessary integration for Garner and Grape. Change:

```ruby
class API < Grape::API
  use Garner::Middleware::Cache::Bust
  helpers Garner::Mixins::Grape::Cache
end
```

to:

```ruby
class API < Grape::API
  helpers Garner::Mixins::Rack
end
```

### Mongoid Integration

The API for Mongoid integration is unchanged. Please continue to include the Mongoid mixin by placing the following code in an initializer:

```ruby
require "garner"
require "garner/mixins/mongoid"

module Mongoid
  module Document
    include Garner::Mixins::Mongoid::Document
  end
end
```

### HTTP Caching

Garner no longer provides HTTP caching, beginning with 0.4.0. We recommend using `Rack::ConditionalGet` in combination with `Rack::ETag` instead. These can be easily mixed into your existing Grape app like so:

```ruby
class API < Grape::API
  use Rack::ConditionalGet
  use Rack::ETag
end
```

Moreover, `cache_or_304` is no longer implemented in Garner 0.4.0. All calls to `cache_or_304` should be replaced with `garner` blocks, just like any `cache` block. To give a specific example,

```ruby
cache_or_304({ bind: [ User, current_user.id ] }) do
  current_user.address
end
```

should become:

```ruby
garner.bind(current_user) do
  current_user.address
end
```

### Context Key Strategies

You should no longer need to explicitly define key strategies. You can remove definitions like:

```ruby
Garner::Cache::ObjectIdentity::KEY_STRATEGIES = [
  # ...
]
```

from your initializers. If you have custom context key strategies, please refer to [request_get.rb](/artsy/garner/blob/master/lib/garner/strategies/context/key/request_get.rb) for an example of how to write new context key strategies. They can be added to `Garner.config.context_key_strategies`, or if only applicable to the Rack context, `Garner.config.rack_context_key_strategies`.
