module Garner
  module Mixins
    module Mongoid
      module Document
        extend ActiveSupport::Concern

        included do
          after_create :invalidate_api_cache_for_class
          after_update :invalidate_api_cache
          after_destroy :invalidate_api_cache
          cattr_accessor :api_cache_class
        end

        # invalidate API cache
        def invalidate_api_cache
          self.all_embedding_documents.each { |doc| doc.invalidate_api_cache }
          cache_class = self.class.api_cache_class || self.class
          Garner::Cache::ObjectIdentity::IDENTITY_FIELDS.each do |identity_field|
            next unless self.respond_to?(identity_field)
            Garner::Cache::ObjectIdentity.invalidate(cache_class, { identity_field => self.send(identity_field) })
          end
        end

        def invalidate_api_cache_for_class
          cache_class = self.class.api_cache_class || self.class
          Garner::Cache::ObjectIdentity.invalidate(cache_class)
        end

        # navigate the parent embedding document hierarchy
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
          # Including classes can call `cache_as` to specify a different class
          # on which to bind API cache objects.
          # @example `Admin`, which extends `User` should call `cache_as User`
          def cache_as(klass)
            self.api_cache_class = klass
          end
        end
      end
    end
  end
end

