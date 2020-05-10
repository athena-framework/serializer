require "./spec_helper"

class Unserializable
  getter id : Int64?
end

class NotNilableModel
  include ASR::Serializable

  getter not_nilable : String
  getter not_nilable_not_serializable : Unserializable
end

class NilableModel
  include ASR::Serializable

  getter not_nilable : String?
  getter not_nilable_not_serializable : Unserializable?
end

describe ASR::Serializer do
  describe "#deserialize" do
    describe ASR::Serializable do
      describe NotNilableModel do
        it "missing" do
          expect_raises Exception, "Missing required attribute: 'not_nilable'." do
            ASR::Serializer.new.deserialize NotNilableModel, %({}), :json
          end
        end

        it nil do
          expect_raises Exception, "Required property 'not_nilable_not_serializable' cannot be nil." do
            ASR::Serializer.new.deserialize NotNilableModel, %({"not_nilable":"FOO","not_nilable_not_serializable":null}), :json
          end
        end
      end

      describe ASR::Accessor do
        it :setter do
          ASR::Serializer.new.deserialize(SetterAccessor, %({"foo":"foo"}), :json).foo.should eq "FOO"
        end
      end

      describe ASR::Discriminator do
        it "happy path" do
          ASR::Serializer.new.deserialize(Shape, %({"x":1,"y":2,"type":"point"}), :json).should be_a Point
        end

        it "missing discriminator" do
          expect_raises(Exception, "Missing discriminator field 'type'.") do
            ASR::Serializer.new.deserialize Shape, %({"x":1,"y":2}), :json
          end
        end

        it "unknown discriminator value" do
          expect_raises(Exception, "Unknown 'type' discriminator value: 'triangle'.") do
            ASR::Serializer.new.deserialize Shape, %({"x":1,"y":2,"type":"triangle"}), :json
          end
        end
      end
    end

    describe "primitive" do
      it nil do
        expect_raises Exception, "Could not parse String from 'nil'." do
          ASR::Serializer.new.deserialize String, "null", :json
        end
      end

      it Int32 do
        value = ASR::Serializer.new.deserialize Int32, "17", :json
        value.should eq 17
        value.should be_a Int32
      end
    end

    describe "non serializable" do
      it "should return `nil`" do
        obj = ASR::Serializer.new.deserialize NilableModel, %({"not_nilable":"FOO","not_nilable_not_serializable":{"id":10}}), :json
        obj.not_nilable.should eq "FOO"
        obj.not_nilable_not_serializable.should be_nil
      end
    end
  end
end
