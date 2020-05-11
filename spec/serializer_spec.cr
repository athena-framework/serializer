require "./spec_helper"

class Unserializable
  getter id : Int64?
end

class IsSerializable
  include ASR::Serializable

  getter id : Int64
end

class NotNilableModel
  include ASR::Serializable

  getter not_nilable : String
  getter not_nilable_not_serializable : Unserializable
end

class NilableModel
  include ASR::Serializable

  getter nilable : String?
  getter nilable_not_serializable : Unserializable?
end

class NilableArrayModel
  include ASR::Serializable

  getter nilable_array : Array(Unserializable)?
  getter default_array : Array(Unserializable)? = [] of Unserializable
  getter nilable_nilable_array : Array(Unserializable?)?
end

class TestingModel
  include ASR::Serializable

  getter id : Int64
  @array : Array(IsSerializable)
  property obj : IsSerializable

  def get_array
    @array
  end
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

      describe NilableModel do
        it "should be set to `nil`" do
          obj = ASR::Serializer.new.deserialize NilableModel, %({"nilable":"FOO","nilable_not_serializable":{"id":10}}), :json
          obj.nilable.should eq "FOO"
          obj.nilable_not_serializable.should be_nil
        end
      end

      describe NilableArrayModel do
        it "should be set to `nil` or default if not provided" do
          obj = ASR::Serializer.new.deserialize NilableArrayModel, %({}), :json
          obj.nilable_array.should be_nil
          obj.default_array.should eq [] of Unserializable
          obj.nilable_nilable_array.should be_nil
        end

        it "should default to an empty array if provided or `nil` if possible" do
          obj = ASR::Serializer.new.deserialize NilableArrayModel, %({"nilable_array":[{"id":1}],"default_array":[{"id":1}],"nilable_nilable_array":[{"id":1}]}), :json
          obj.nilable_array.should eq [] of Unserializable
          obj.default_array.should eq [] of Unserializable
          obj.nilable_nilable_array.should eq [nil]
        end
      end

      describe TestingModel do
        it "should deserialize correctly" do
          obj = ASR::Serializer.new.deserialize TestingModel, %({"id":1,"array":[{"id":2},{"id":3}],"obj":{"id":4}}), :json
          obj.id.should eq 1

          array = obj.get_array
          array.size.should eq 2
          array[0].id.should eq 2
          array[1].id.should eq 3

          obj.obj.id.should eq 4
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
  end
end
