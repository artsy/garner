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
  context "key" do
    it "nil" do
      lambda { subject.key(nil) }.should raise_error(ArgumentError, "you cannot key nil")
    end
    it "generates an MD5 pair for class and object with id" do
      key_pair = subject.key(:bind => { :klass => Module, :object => { :id => 42 } }).split(":")
      key_pair.length.should == 2
      key_pair[0].length.should == 32 # MD5
      key_pair[0].length.should == key_pair[1].length
    end
    it "generates the same key twice" do
      key1 = subject.key(:bind => { :klass => Module, :object => { :id => 42 } })
      key2 = subject.key(:bind => { :klass => Module, :object => { :id => 42 } })
      key1.should == key2
    end
    it "generates a different key for different IDs" do
      key1 = subject.key(:bind => { :klass => Module, :object => { :id => 42 } })
      key2 = subject.key(:bind => { :klass => Module, :object => { :id => 24 } })
      key1.should_not == key2
    end
    it "standardizes shortcuts" do
      key1 = subject.key(:bind => [Module])
      key2 = subject.key(:bind => { :klass => Module })
      key1.should == key2
    end
  end
end
