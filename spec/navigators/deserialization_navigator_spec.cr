require "../spec_helper"

private record NonSerializable

private def create_deserialization_navigator(expected_type = Nil, & : ASR::Navigators::DeserializationNavigatorInterface, IO -> Nil) : Nil
  io = IO::Memory.new
  navigator = ASR::Navigators::DeserializationNavigator.new(TestDeserializationVisitor.new(io), ASR::DeserializationContext.new, TestObjectConstructor.new(expected_type))
  yield navigator, io
end

describe ASR::Navigators::DeserializationNavigator do
  describe "#accept" do
    describe ASR::PostDeserialize do
      it "should run post deserilize methods" do
        data = JSON.parse %({"name": "First Last"})

        visitor = create_deserialization_visitor do |properties|
          properties.size.should eq 1
          p = properties[0]

          p.name.should eq "name"
          p.external_name.should eq "name"
          p.skip_when_empty?.should be_false
          p.groups.should eq ["default"] of String
          p.type.should eq String?
          p.class.should eq PostDeserialize

          obj = PostDeserialize.new

          obj.first_name.should be_nil
          obj.last_name.should be_nil

          obj
        end

        obj = ASR::Navigators::DeserializationNavigator.new(visitor, ASR::DeserializationContext.new).accept(PostDeserialize, data).as(PostDeserialize)

        obj.first_name.should eq "First"
        obj.last_name.should eq "Last"
      end
    end

    it "should not invoke the visitor for unsupported type" do
      create_deserialization_navigator do |navigator, io|
        navigator.accept NonSerializable, JSON.parse(%({"blah":"blah"}))
        io.to_s.should be_empty
      end
    end

    describe ASR::Discriminator do
      it "happy path" do
        create_deserialization_navigator(Point) do |navigator, io|
          navigator.accept Shape, JSON.parse(%({"x":1,"y":2,"type":"point"}))
        end
      end

      it "missing discriminator" do
        create_deserialization_navigator do |navigator, io|
          expect_raises(Exception, "Missing discriminator field 'type'.") do
            navigator.accept Shape, JSON.parse(%({"x":1,"y":2}))
          end
        end
      end

      it "unknown discriminator value" do
        create_deserialization_navigator do |navigator, io|
          expect_raises(Exception, "Unknown 'type' discriminator value: 'triangle'.") do
            navigator.accept Shape, JSON.parse(%({"x":1,"y":2,"type":"triangle"}))
          end
        end
      end
    end

    describe "primitive type" do
      it "should write the value" do
        create_deserialization_navigator do |navigator, io|
          navigator.accept Int32, JSON.parse("18")
          io.to_s.should eq "18"
        end
      end
    end
  end
end
