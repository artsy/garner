require 'spec_helper'

describe Garner::Strategies::Bindings::ObjectIdentity do
  subject do
    Garner::Strategies::Bindings::ObjectIdentity
  end
  context "apply" do
    it "nil" do
      subject.apply(nil).should eq({})
    end
    it "class and object with id" do
      subject.apply(:bind => { :klass => Module, :object => { :id => 42 } }).should eq({
        :bind => { :klass => Module, :object => { :id => 42 } }
      })
    end
    it "class" do
      subject.apply(:bind => { :klass => Module }).should eq({
        :bind => { :klass => Module }
      })
    end
    it "class and class with object with id" do
      subject.apply(:bind => [{ :klass => Module }, { :klass => Class, :object => { :id => 42 } }]).should eq({
        :bind => [{ :klass => Module }, { :klass => Class, :object => { :id => 42 } }]
      })
    end
    context "shorthands" do
      it "array of type" do
        subject.apply(:bind => [Module]).should eq({ :bind => { :klass => Module } })
      end
      it "array of type and id" do
        subject.apply(:bind => [Module, 42]).should eq({ 
          :bind => { :klass => Module, :object => { :id => 42 } }
        })
      end
      it "array of types" do
        subject.apply(:bind => [[Module], [Class, { :id => 42 }]]).should eq({
          :bind => [{ :klass => Module }, { :klass => Class, :object => { :id => 42 }}]
        })
      end
    end
  end
end
