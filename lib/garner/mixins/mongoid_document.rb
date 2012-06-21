module Garner
  module Mixins
    module Mongoid
      module Document
        extend ActiveSupport::Concern

        included do
          before_save :invalidate_api_cache
          before_destroy :invalidate_api_cache
          cattr_accessor :api_cache_class
        end

        def invalidate_api_cache
          self.all_embedding_documents.each { |doc| doc.invalidate_api_cache }
          cache_class = self.class.api_cache_class || self.class
          Garner::Cache::ObjectIdentity.invalidate(cache_class, { id: self.id })
          Garner::Cache::ObjectIdentity.invalidate(cache_class)
        end

        # Wrapper for navigating the parent embedding document hierarchy.
        def all_embedding_documents
          obj = self
          docs = []
          while obj.metadata && obj.embedded?
            break if docs.detect { |doc| doc.class == obj.class }
            parent = obj.send(obj.metadata.inverse)
            docs << parent
            obj = parent
          end
          docs
        end

        module ClassMethods
          # Including classes can call cache as to specify a different class
          # on which to bind API cache objects. For example, Admin (which
          # extends User), can.
          def cache_as(klass)
            self.api_cache_class = klass
          end
        end
      end
    end
  end
end

