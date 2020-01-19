require "spec"
require "../src/athena-serializer"

require "./models/*"

enum TestEnum
  Zero
  One
  Two
  Three
end

class EmptyObject
  include ASR::Serializable
end

class NestedType
  include ASR::Serializable

  getter active : Bool = true
end

class TestObject
  include ASR::Serializable

  getter foo : Symbol = :foo
  getter bar : Float32 = 12.1_f32
  getter nest : NestedType = NestedType.new
end

class TestVisitor < Athena::Serializer::Visitors::SerializationVisitorInterface
  def initialize(@io : IO, named_args : NamedTuple) : Nil
  end

  def assert_properties(handler : Proc(Array(ASR::PropertyMetadataBase), Nil)) : Nil
    @assert_properties = handler
  end

  def prepare : Nil
  end

  def finish : Nil
  end

  def visit(data : Array(ASR::PropertyMetadataBase)) : Nil
    @assert_properties.try &.call data
  end

  def visit(data : _) : Nil
  end
end

private struct TestNavigator < Athena::Serializer::Navigators::Navigator
  def accept(data : ASR::Serializable) : Nil
    @visitor.visit data.serialization_properties
  end

  def accept(data : _) : Nil
    @visitor.visit data
  end
end

def get_test_property_metadata : Array(ASR::PropertyMetadataBase)
  [ASR::PropertyMetadata(String, TestObject).new(
    name: "name",
    external_name: "external_name",
    value: "YES",
    skip_when_empty: false,
    groups: ["default"],
    since_version: nil,
    until_version: nil,
  )] of ASR::PropertyMetadataBase
end

def create_visitor(&block : Array(ASR::PropertyMetadataBase) -> Nil)
  visitor = TestVisitor.new IO::Memory.new, NamedTuple.new
  visitor.assert_properties block
  visitor
end

# Asserts the output of the given *visitor_type*.
def assert_output(visitor_type : ASR::Visitors::SerializationVisitorInterface.class, expected : String, **named_args, & : ASR::Visitors::SerializationVisitorInterface -> Nil)
  io = IO::Memory.new

  visitor = visitor_type.new io, named_args
  navigator = TestNavigator.new visitor, ASR::SerializationContext.new
  visitor.navigator = navigator

  visitor.prepare

  yield visitor

  visitor.finish

  io.rewind.gets_to_end.should eq expected
end
