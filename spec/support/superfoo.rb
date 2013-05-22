class Superfoo
  include Mongoid::Document
  include Garner::Mixins::Mongoid::Document
  embeds_many :foos
end
