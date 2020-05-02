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

  def initialize; end
end

class NestedType
  include ASR::Serializable

  def initialize; end

  getter active : Bool = true
end

class TestObject
  include ASR::Serializable

  def initialize; end

  getter foo : Symbol = :foo
  getter bar : Float32 = 12.1_f32
  getter nest : NestedType = NestedType.new
end

class TestSerializationVisitor
  include Athena::Serializer::Visitors::SerializationVisitorInterface

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

class TestDeserializationVisitor
  include Athena::Serializer::Visitors::DeserializationVisitorInterface

  def initialize(@io : IO) : Nil
  end

  def assert_properties(handler : Proc(Array(ASR::PropertyMetadataBase), ASR::Serializable)) : Nil
    @assert_properties = handler
  end

  def prepare(data : IO | String) : ASR::Any
    ASR::Any.new ""
  end

  def finish : Nil
  end

  def visit(type : _, properties : Array(ASR::PropertyMetadataBase), data : _)
    @assert_properties.not_nil!.call properties
  end

  def visit(type : _, data : _) : Nil
    @io << data
  end
end

private struct TestSerializationNavigator
  include Athena::Serializer::Navigators::SerializationNavigatorInterface

  def initialize(@visitor : ASR::Visitors::SerializationVisitorInterface, @context : ASR::SerializationContext); end

  def accept(data : ASR::Serializable) : Nil
    @visitor.visit data.serialization_properties
  end

  def accept(data : _) : Nil
    @visitor.visit data
  end
end

private struct TestDeserializationNavigator
  include Athena::Serializer::Navigators::DeserializationNavigatorInterface

  def initialize(@visitor : ASR::Visitors::DeserializationVisitorInterface, @context : ASR::DeserializationContext); end

  def accept(type : ASR::Serializable.class, data : ASR::Any) : ASR::Serializable
    @visitor.visit type, type.deserialization_properties, data
  end

  def accept(type : _, data : ASR::Any)
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

def create_serialization_visitor(&block : Array(ASR::PropertyMetadataBase) -> Nil)
  visitor = TestSerializationVisitor.new IO::Memory.new, NamedTuple.new
  visitor.assert_properties block
  visitor
end

def create_deserialization_visitor(&block : Array(ASR::PropertyMetadataBase) -> ASR::Serializable)
  visitor = TestDeserializationVisitor.new IO::Memory.new
  visitor.assert_properties block
  visitor
end

def assert_deserialized_output(visitor_type : ASR::Visitors::DeserializationVisitorInterface.class, type : _, data : _, expected : _)
  visitor = visitor_type.new
  navigator = TestDeserializationNavigator.new(visitor, ASR::DeserializationContext.new)
  visitor.navigator = navigator

  result = visitor.visit(type, visitor.prepare(data))
  result.should eq expected
  typeof(result).should eq type
end

# Asserts the output of the given *visitor_type*.
def assert_serialized_output(visitor_type : ASR::Visitors::SerializationVisitorInterface.class, expected : String, **named_args, & : ASR::Visitors::SerializationVisitorInterface -> Nil)
  io = IO::Memory.new

  visitor = visitor_type.new io, named_args
  navigator = TestSerializationNavigator.new(visitor, ASR::SerializationContext.new)
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
