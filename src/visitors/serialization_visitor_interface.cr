module Athena::Serializer::Visitors::SerializationVisitorInterface
  abstract def initialize(io : IO, named_arguments : NamedTuple) : Nil

  abstract def prepare : Nil
  abstract def finish : Nil

  abstract def visit(data : Array(ASR::PropertyMetadataBase)) : Nil
  abstract def visit(data : Bool) : Nil
  abstract def visit(data : Enum) : Nil
  abstract def visit(data : Enumerable) : Nil
  abstract def visit(data : Hash) : Nil
  abstract def visit(data : JSON::Any) : Nil
  abstract def visit(data : NamedTuple) : Nil
  abstract def visit(data : Nil) : Nil
  abstract def visit(data : Number) : Nil
  abstract def visit(data : Serializable) : Nil
  abstract def visit(data : String) : Nil
  abstract def visit(data : Symbol) : Nil
  abstract def visit(data : Time) : Nil
  abstract def visit(data : UUID) : Nil
  abstract def visit(data : YAML::Any) : Nil
end
