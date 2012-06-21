class Foo
  include Mongoid::Document
  include Garner::Mixins::Mongoid::Document
  embeds_one :bars
  embedded_in :bar
end
