module Garner
  module Mixins
    module Rack

      def cache_enabled?
        true
      end

      # cache a record
      def garner(options = {}, &block)
        unless cache_enabled?
          yield
        else
          binding, context = cache_binding_and_context(options)
          Garner::Cache.fetch(binding, context) do
            yield
          end
        end
      end

      private
      def cache_binding_and_context(options)
        cache_context = {}
        cache_context.merge!(options.dup)
        cache_context[:request] = request
        cache_context[:version] = version if self.respond_to?(:version) && version
        cache_context.delete(:bind)
        cache_binding = (options || {})[:bind]
        cache_binding = cache_binding ? { :bind => cache_binding } : {}
        [ cache_binding, cache_context ]
      end
    end
  end
end
