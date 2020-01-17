abstract struct Athena::Serializer::SerializationVisitorInterface
  abstract def initialize(io : IO) : Nil

  # Entrypoint for serializing `ASR::Serializable` types.  Should only be called once at the start of serializaiton.
  abstract def accept(properties : Array(Metadata)) : Nil

  # Entrypoint for serializing primitive types.  Should only be called once at the start of serializaiton.
  abstract def accept(data : _) : Nil

  abstract def visit(data : Nil) : Nil
  abstract def visit(data : String) : Nil
  abstract def visit(data : Number) : Nil
  abstract def visit(data : Bool) : Nil
  abstract def visit(data : Array | Set | Deque | Tuple) : Nil
  abstract def visit(data : Hash) : Nil
  abstract def visit(data : Serializable) : Nil
end
