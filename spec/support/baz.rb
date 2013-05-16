class Baz
  include Mongoid::Document
  include Garner::Mixins::Mongoid::Document
  embedded_in :foo
end
