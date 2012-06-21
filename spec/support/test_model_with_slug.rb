class TestModelWithSlug
  include Mongoid::Document
  include Garner::Mixins::Mongoid::Document
  
  field :slug, :type => String
end