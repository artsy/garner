require "spec_helper"
require "garner/mixins/mongoid"

describe Garner::Mixins::Mongoid::Document do
  before(:each) do
    module Mongoid
      module Document
        include Garner::Mixins::Mongoid::Document
      end
    end
  end

  context "with a Mongoid document model" do
    subject do
      class TestModel
        include Mongoid::Document
      end
      TestModel
    end
  end

end
