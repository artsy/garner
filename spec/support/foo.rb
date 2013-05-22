class Foo
  include Mongoid::Document
  include Garner::Mixins::Mongoid::Document
  embeds_one :bar
  embeds_many :bazs
  embedded_in :bar
  embedded_in :superfoo
end
