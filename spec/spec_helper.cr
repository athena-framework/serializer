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
    @io << data
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

def create_metadata(*, name : String = "name", external_name : String = "external_name", value : I = "value", skip_when_empty : Bool = false, groups : Array(String) = ["default"], since_version : String? = nil, until_version : String? = nil) : ASR::PropertyMetadata forall I
  context = ASR::PropertyMetadata(I, EmptyObject).new name, external_name, value, skip_when_empty, groups

  context.since_version = SemanticVersion.parse since_version if since_version
  context.until_version = SemanticVersion.parse until_version if until_version

  context
end

def assert_version(*, since_version : String? = nil, until_version : String? = nil) : Bool
  ASR::ExclusionStrategies::Version.new(SemanticVersion.parse "1.0.0").skip_property?(create_metadata(since_version: since_version, until_version: until_version), ASR::SerializationContext.new)
end

def assert_groups(*, groups : Array(String), metadata_groups : Array(String) = ["default"]) : Bool
  ASR::ExclusionStrategies::Groups.new(groups).skip_property?(create_metadata(groups: metadata_groups), ASR::SerializationContext.new)
end
